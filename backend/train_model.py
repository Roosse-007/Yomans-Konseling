import pandas as pd
from sklearn.tree import DecisionTreeClassifier
import joblib

# ================= LOAD DATASET =================
df = pd.read_csv("dataset.csv")

# ================= FITUR =================
X = df.drop("hasil", axis=1)

# ================= TARGET =================
y = df["hasil"]

# ================= MODEL =================
model = DecisionTreeClassifier(
    criterion='entropy',
    max_depth=6,
    min_samples_split=2,
    random_state=42
)

# ================= TRAINING =================
model.fit(X, y)

# ================= SIMPAN MODEL =================
joblib.dump(model, "model.pkl")

print("MODEL BERHASIL DIBUAT")