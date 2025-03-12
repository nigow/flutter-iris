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

knn = KNeighborsClassifier(n_neighbors=3)
knn.fit(X, y)

feature_descriptions = [('input', cml.models.datatypes.Array(4))]

coreml_model = cml.converters.sklearn.convert(
    knn,
    feature_descriptions,
    'species'
)

coreml_model.save("IrisClassifier.mlmodel")
print("CoreML model saved as IrisClassifier.mlmodel")

# first run `xcrun coremlc compile IrisClassifier.mlmodel .` to compile the model
# place IrisClassifier.mlmodelc in copied bundle resources on xcode

# Test
test_data = [6.1, 2.8, 4.7, 1.2]
pred = knn.predict([test_data])
print("SKLearn prediction:", iris.target_names[pred[0]])

