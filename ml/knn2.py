import coremltools as cml
import json
from sklearn.neighbors import KNeighborsClassifier
from sklearn.datasets import load_iris
from coremltools.models.datatypes import Double

iris = load_iris()
X = iris.data
y = iris.target

knn = KNeighborsClassifier(n_neighbors=3)
knn.fit(X, y)

# Define input features as a dictionary instead of array
feature_descriptions = {
    'sepal_length': Double(),
    'sepal_width': Double(),
    'petal_length': Double(),
    'petal_width': Double()
}


def convert_dict_to_array(input_dict):
    return [
        float(input_dict['sepal_length']),
        float(input_dict['sepal_width']),
        float(input_dict['petal_length']),
        float(input_dict['petal_width'])
    ]


# Create the model with a preprocessor that converts dict to array
coreml_model = cml.converters.sklearn.convert(
    knn,
    feature_descriptions,
    'species',
)

coreml_model.save("IrisClassifier.mlmodel")
print("CoreML model saved as IrisClassifier.mlmodel")

# Test with JSON input
test_json = '''
{
    "sepal_length": 6.1,
    "sepal_width": 2.8,
    "petal_length": 4.7,
    "petal_width": 1.2
}
'''
test_data = json.loads(test_json)
test_array = convert_dict_to_array(test_data)
pred = knn.predict([test_array])
print("SKLearn prediction:", iris.target_names[pred[0]])
