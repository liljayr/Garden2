from fastapi import FastAPI, Header, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore, auth
import uuid

# ─── Firebase Setup ────────────────────────────────────────

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

# ─── App Setup ─────────────────────────────────────────────

app = FastAPI(title="My Garden API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── AUTH HELPERS ──────────────────────────────────────────

def get_current_user(authorization: str = Header(None)):
    """
    Verifies Firebase ID token sent from Flutter
    """
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")

    token = authorization.replace("Bearer ", "")

    try:
        decoded = auth.verify_id_token(token)
        return decoded  # contains uid, email, etc.
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

# ─── MODELS ────────────────────────────────────────────────

class GratitudeEntry(BaseModel):
    id: Optional[str] = None
    text: str
    date: Optional[str] = None


class StrengthItem(BaseModel):
    id: Optional[str] = None
    name: str
    selected: bool = True


class JournalEntry(BaseModel):
    id: Optional[str] = None
    title: str
    content: str
    date: Optional[str] = None


class Friend(BaseModel):
    id: Optional[str] = None
    name: str
    emoji: Optional[str] = "🌱"
    note: Optional[str] = ""


class Message(BaseModel):
    id: Optional[str] = None
    sender_id: Optional[str] = None
    recipient_id: str
    content: str
    timestamp: Optional[str] = None

# ─── USERS (NEW) ───────────────────────────────────────────

@app.post("/users")
def create_user(user=Depends(get_current_user)):
    uid = user["uid"]

    db.collection("users").document(uid).set({
        "email": user.get("email"),
        "created_at": datetime.utcnow().isoformat()
    }, merge=True)

    return {"status": "user created", "uid": uid}


@app.get("/me")
def get_me(user=Depends(get_current_user)):
    return user

# ─── GRATITUDE ─────────────────────────────────────────────

@app.get("/gratitude")
def get_gratitude(user=Depends(get_current_user)):
    docs = db.collection("gratitude").order_by(
        "date", direction=firestore.Query.DESCENDING
    ).stream()

    return [{**doc.to_dict(), "id": doc.id} for doc in docs]


@app.post("/gratitude")
def add_gratitude(entry: GratitudeEntry, user=Depends(get_current_user)):
    entry_dict = entry.dict()
    entry_dict["date"] = datetime.utcnow().isoformat()

    doc_ref = db.collection("gratitude").document()
    doc_ref.set(entry_dict)

    return {"id": doc_ref.id, **entry_dict}


@app.delete("/gratitude/{entry_id}")
def delete_gratitude(entry_id: str, user=Depends(get_current_user)):
    db.collection("gratitude").document(entry_id).delete()
    return {"status": "deleted"}

# ─── STRAIGHTFORWARD (unchanged logic, just secured optionally) ─────────────

DEFAULT_STRENGTHS = [
    "Creativity", "Curiosity", "Kindness", "Leadership", "Bravery",
    "Honesty", "Perseverance", "Teamwork", "Empathy", "Humor",
    "Patience", "Gratitude", "Love of Learning", "Fairness", "Forgiveness",
    "Spirituality", "Prudence", "Self-Regulation", "Zest", "Hope"
]


@app.get("/strengths")
def get_strengths(user=Depends(get_current_user)):
    docs = list(db.collection("strengths").stream())

    if not docs:
        for s in DEFAULT_STRENGTHS:
            db.collection("strengths").add({
                "name": s,
                "selected": False
            })

        docs = db.collection("strengths").stream()

    return [{**doc.to_dict(), "id": doc.id} for doc in docs]


@app.put("/strengths")
def update_strengths(strengths: List[StrengthItem], user=Depends(get_current_user)):
    for s in strengths:
        db.collection("strengths").document(s.id).set(s.dict())
    return {"status": "updated"}

# ─── JOURNAL ───────────────────────────────────────────────

@app.get("/journal")
def get_journal(user=Depends(get_current_user)):
    docs = db.collection("journal").order_by(
        "date", direction=firestore.Query.DESCENDING
    ).stream()

    return [{**doc.to_dict(), "id": doc.id} for doc in docs]


@app.post("/journal")
def add_journal(entry: JournalEntry, user=Depends(get_current_user)):
    entry_dict = entry.dict()
    entry_dict["date"] = datetime.utcnow().isoformat()

    doc_ref = db.collection("journal").document()
    doc_ref.set(entry_dict)

    return {"id": doc_ref.id, **entry_dict}


@app.put("/journal/{entry_id}")
def update_journal(entry_id: str, entry: JournalEntry, user=Depends(get_current_user)):
    doc_ref = db.collection("journal").document(entry_id)

    if not doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="Entry not found")

    doc_ref.set(entry.dict())
    return {"id": entry_id, **entry.dict()}


@app.delete("/journal/{entry_id}")
def delete_journal(entry_id: str, user=Depends(get_current_user)):
    db.collection("journal").document(entry_id).delete()
    return {"status": "deleted"}

# ─── FRIENDS (optional feature now, not required for messaging) ─────────────

@app.get("/friends")
def get_friends(user=Depends(get_current_user)):
    docs = db.collection("friends").stream()
    return [{**doc.to_dict(), "id": doc.id} for doc in docs]


@app.post("/friends")
def add_friend(friend: Friend, user=Depends(get_current_user)):
    doc_ref = db.collection("friends").document()
    doc_ref.set(friend.dict())
    return {"id": doc_ref.id, **friend.dict()}

# ─── MESSAGING (REAL USER-TO-USER SYSTEM) ─────────────────

@app.post("/messages")
def send_message(message: Message, user=Depends(get_current_user)):
    sender_id = user["uid"]

    msg_dict = message.dict()
    msg_dict["sender_id"] = sender_id
    msg_dict["timestamp"] = datetime.utcnow().isoformat()

    doc_ref = db.collection("messages").document()
    doc_ref.set(msg_dict)

    return {"id": doc_ref.id, **msg_dict}


@app.get("/messages/{other_user_id}")
def get_messages(other_user_id: str, user=Depends(get_current_user)):
    uid = user["uid"]

    docs = db.collection("messages").stream()

    messages = []

    for doc in docs:
        data = doc.to_dict()

        if (
            (data.get("sender_id") == uid and data.get("recipient_id") == other_user_id)
            or
            (data.get("sender_id") == other_user_id and data.get("recipient_id") == uid)
        ):
            messages.append({**data, "id": doc.id})

    messages.sort(key=lambda x: x["timestamp"])
    return messages

# ─── RUN ───────────────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)


# from fastapi import FastAPI, Header, HTTPException
# from fastapi.middleware.cors import CORSMiddleware
# from pydantic import BaseModel
# from typing import List, Optional
# from datetime import datetime
# import firebase_admin
# from firebase_admin import credentials, firestore
# import uuid

# # ─── Firebase Setup ────────────────────────────────────────

# cred = credentials.Certificate("serviceAccountKey.json")
# firebase_admin.initialize_app(cred)
# db = firestore.client()

# # ─── App Setup ─────────────────────────────────────────────

# app = FastAPI(title="My Garden API")

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # ─── API Key ────────────────────────────────────────────────

# API_KEY = "supersecret123"

# def verify_api_key(x_api_key: str = Header(...)):
#     if x_api_key != API_KEY:
#         raise HTTPException(status_code=401, detail="Unauthorized")

# # ─── Models ────────────────────────────────────────────────

# class GratitudeEntry(BaseModel):
#     id: Optional[str] = None
#     text: str
#     date: Optional[str] = None

# class StrengthItem(BaseModel):
#     id: Optional[str] = None
#     name: str
#     selected: bool = True

# class JournalEntry(BaseModel):
#     id: Optional[str] = None
#     title: str
#     content: str
#     date: Optional[str] = None

# class Friend(BaseModel):
#     id: Optional[str] = None
#     name: str
#     emoji: Optional[str] = "🌱"
#     note: Optional[str] = ""
#     strengths: Optional[List[str]] = []

# class Message(BaseModel):
#     id: Optional[str] = None
#     friend_id: str
#     content: str
#     from_me: bool = True
#     timestamp: Optional[str] = None

# # ─── Gratitude ─────────────────────────────────────────────

# @app.get("/gratitude")
# def get_gratitude():
#     docs = db.collection("gratitude").order_by("date", direction=firestore.Query.DESCENDING).stream()
#     return [{**doc.to_dict(), "id": doc.id} for doc in docs]

# @app.post("/gratitude")
# def add_gratitude(entry: GratitudeEntry):
#     entry_dict = entry.dict()
#     entry_dict["date"] = datetime.utcnow().isoformat()
#     doc_ref = db.collection("gratitude").document()
#     doc_ref.set(entry_dict)
#     return {"id": doc_ref.id, **entry_dict}

# @app.delete("/gratitude/{entry_id}")
# def delete_gratitude(entry_id: str):
#     db.collection("gratitude").document(entry_id).delete()
#     return {"status": "deleted"}

# # ─── Strengths ─────────────────────────────────────────────

# DEFAULT_STRENGTHS = [
#     "Creativity", "Curiosity", "Kindness", "Leadership", "Bravery",
#     "Honesty", "Perseverance", "Teamwork", "Empathy", "Humor",
#     "Patience", "Gratitude", "Love of Learning", "Fairness", "Forgiveness",
#     "Spirituality", "Prudence", "Self-Regulation", "Zest", "Hope"
# ]

# @app.get("/strengths")
# def get_strengths():
#     docs = list(db.collection("strengths").stream())

#     if not docs:
#         for i, s in enumerate(DEFAULT_STRENGTHS):
#             db.collection("strengths").add({
#                 "name": s,
#                 "selected": False
#             })

#         docs = db.collection("strengths").stream()

#     return [{**doc.to_dict(), "id": doc.id} for doc in docs]

# @app.put("/strengths")
# def update_strengths(strengths: List[StrengthItem]):
#     for s in strengths:
#         db.collection("strengths").document(s.id).set(s.dict())
#     return {"status": "updated"}

# @app.post("/strengths")
# def add_strength(strength: StrengthItem):
#     doc_ref = db.collection("strengths").document()
#     doc_ref.set(strength.dict())
#     return {"id": doc_ref.id, **strength.dict()}

# # ─── Journal ───────────────────────────────────────────────

# @app.get("/journal")
# def get_journal():
#     docs = db.collection("journal").order_by("date", direction=firestore.Query.DESCENDING).stream()
#     return [{**doc.to_dict(), "id": doc.id} for doc in docs]

# @app.post("/journal")
# def add_journal(entry: JournalEntry):
#     entry_dict = entry.dict()
#     entry_dict["date"] = datetime.utcnow().isoformat()
#     doc_ref = db.collection("journal").document()
#     doc_ref.set(entry_dict)
#     return {"id": doc_ref.id, **entry_dict}

# @app.put("/journal/{entry_id}")
# def update_journal(entry_id: str, entry: JournalEntry):
#     doc_ref = db.collection("journal").document(entry_id)

#     if not doc_ref.get().exists:
#         raise HTTPException(status_code=404, detail="Entry not found")

#     entry_dict = entry.dict()
#     doc_ref.set(entry_dict)
#     return {"id": entry_id, **entry_dict}

# @app.delete("/journal/{entry_id}")
# def delete_journal(entry_id: str):
#     db.collection("journal").document(entry_id).delete()
#     return {"status": "deleted"}

# # ─── Friends ───────────────────────────────────────────────

# @app.get("/friends")
# def get_friends():
#     docs = db.collection("friends").stream()
#     return [{**doc.to_dict(), "id": doc.id} for doc in docs]

# @app.post("/friends")
# def add_friend(friend: Friend):
#     doc_ref = db.collection("friends").document()
#     doc_ref.set(friend.dict())
#     return {"id": doc_ref.id, **friend.dict()}

# @app.put("/friends/{friend_id}")
# def update_friend(friend_id: str, friend: Friend):
#     doc_ref = db.collection("friends").document(friend_id)

#     if not doc_ref.get().exists:
#         raise HTTPException(status_code=404, detail="Friend not found")

#     doc_ref.set(friend.dict())
#     return {"id": friend_id, **friend.dict()}

# @app.delete("/friends/{friend_id}")
# def delete_friend(friend_id: str):
#     db.collection("friends").document(friend_id).delete()
#     return {"status": "deleted"}

# # ─── Messages ──────────────────────────────────────────────

# @app.get("/messages/{friend_id}")
# def get_messages(friend_id: str):
#     docs = db.collection("messages") \
#         .where("friend_id", "==", friend_id) \
#         .order_by("timestamp") \
#         .stream()

#     return [{**doc.to_dict(), "id": doc.id} for doc in docs]

# @app.post("/messages")
# def send_message(message: Message):
#     msg_dict = message.dict()
#     msg_dict["timestamp"] = datetime.utcnow().isoformat()

#     doc_ref = db.collection("messages").document()
#     doc_ref.set(msg_dict)

#     # Simulated reply
#     if message.from_me:
#         import random
#         replies = [
#             "That's so thoughtful of you! 🌸",
#             "Thank you for reaching out! 💚",
#             "You're amazing! 🌻",
#             "That made my day! ✨",
#             "Sending good vibes back! 🌿"
#         ]

#         reply = {
#             "friend_id": message.friend_id,
#             "content": random.choice(replies),
#             "from_me": False,
#             "timestamp": datetime.utcnow().isoformat()
#         }

#         db.collection("messages").add(reply)

#     return {"id": doc_ref.id, **msg_dict}

# # ─── Run ───────────────────────────────────────────────────

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)