from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml import Pipeline
from pyspark.ml.feature import VectorAssembler
from pyspark.mllib.evaluation import MulticlassMetrics
import sys
import pyspark.sql.functions as func
import pyspark
# import findspark
# findspark.init()

conf = SparkConf().setAppName("Wine Quality Testing").setMaster("local[1]")
sc = SparkContext(conf=conf)

spark = SparkSession.builder.getOrCreate()

rf = RandomForestClassifier.load("s3://winefile/wine.model")

defTest = spark.read.format('csv').options(header='true', inferSchema='true', delimiter=';').csv(
    "s3://winefile/ValidationDataset.csv")
defTest.printSchema()

featureColumns = [col for col in defTest.columns if (
    col != '""""quality"""""')]

assembler = VectorAssembler(inputCols=featureColumns, outputCol='features')

rfPipeline = Pipeline(stages=[assembler, rf])

fit = rfPipeline.fit(defTest)
transformed = fit.transform(defTest)
transformed = transformed.withColumn('""""quality"""""', transformed['""""quality"""""'].cast(
    'double')).withColumnRenamed('""""quality"""""', "label")

results = transformed.select(['prediction', 'label'])
predictionAndLabels = results.rdd

metrics = MulticlassMetrics(predictionAndLabels)
predictionAndLabels.take(5)

# Calculate the Accuracy, Precision and Recall 

cm = metrics.confusionMatrix().toArray()
print(cm)

print("( Precision, Recall, Accuracy, F1 Score)")
print(round(metrics.precision(), 2), ", ", round(metrics.recall(), 2),", ", round(metrics.accuracy, 2), ", ", round(metrics.fMeasure(), 2))
