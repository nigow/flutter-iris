import numpy as np
import coremltools as cml
from sklearn.neighbors import KNeighborsClassifier
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from coremltools.models.datatypes import Array

iris = load_iris()
X = iris.data
y = iris.target
feature_names = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

knn = KNeighborsClassifier(n_neighbors=3)
knn.fit(X_train_scaled, y_train)

accuracy = knn.score(scaler.transform(X_test), y_test)
print(f"Model accuracy: {accuracy:.4f}")

input_features = [
    ("sepal_length", Array(1)),
    ("sepal_width", Array(1)),
    ("petal_length", Array(1)),
    ("petal_width", Array(1))
]

coreml_model = cml.converters.sklearn.convert(
    scaler,
    input_features=input_features
)

coreml_model.save("IrisClassifier.mlmodel")
print("CoreML model saved as IrisClassifier.mlmodel")

# Test
scaled_input = scaler.transform([[6.1, 2.8, 4.7, 1.2]]) 

sample_input = {
    "sepal_length": np.array([6.1]),
    "sepal_width": np.array([2.8]),
    "petal_length": np.array([4.7]),
    "petal_width": np.array([1.2])
}

try:
    prediction = coreml_model.predict(sample_input)
    print("CoreML Prediction:", prediction)
except Exception as e:
    print("Prediction failed:", e)

