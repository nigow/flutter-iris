import numpy as np
import pandas as pd
from sklearn.neighbors import KNeighborsClassifier
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import coremltools as cml
import coremltools.models.utils as utils

iris = load_iris()
X = iris.data
y = iris.target
feature_names = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

knn = KNeighborsClassifier(n_neighbors=3)
knn.fit(X_train_scaled, y_train)

accuracy = knn.score(X_test_scaled, y_test)
print(f"Model accuracy: {accuracy:.4f}")

pipeline = Pipeline([
    ('scaler', scaler),
    ('knn', knn)
])

input_features = [cml.TensorType(name=name, shape=(1,)).__str__() for name in feature_names]

coreml_model = cml.converters.sklearn.convert(
    pipeline,
    input_features=input_features,
)

coreml_model.author = "Flutter App Developer"
coreml_model.license = "MIT"
coreml_model.short_description = "Iris Species Classifier using KNN"
coreml_model.version = "1.0"

coreml_model.save("IrisClassifier.mlmodel")
print("CoreML model saved as IrisClassifier.mlmodel")

print("\nModel Specification:")
print(coreml_model.get_spec())

sample_input = {name: np.array([X_test[0][i]]) for i, name in enumerate(feature_names)}
print("\nSample input:", sample_input)

try:
    prediction = coreml_model.predict(sample_input)
    print("CoreML Prediction:", prediction)
except Exception as e:
    print("Prediction failed:", e)

print("\nThe CoreML model is ready to be integrated into your Flutter iOS app.")
