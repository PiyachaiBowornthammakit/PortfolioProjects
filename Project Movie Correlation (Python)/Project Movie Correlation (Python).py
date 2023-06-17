# -*- coding: utf-8 -*-

# -- Sheet --

#import libraries
import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

%matplotlib inline
matplotlib.rcParams['figure.figsize'] = (8, 6) #Adjusts the configuration of the plots we will create

#Read in the data
df = pd.read_csv('movies.csv')

#Look at the data
df.head()

#if there is any missing data
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, pct_missing))

df[ df[col].isnull() ]

#Data types for our columns
df.dtypes

#change data type of columns
df['budget'] = df['budget'].astype('int')
df['gross'] = df['gross'].astype('int')

#i can't change data type because col 'budget' and 'gross' have missing value
#i fill missing value = mean() and change data type again
df['score'].fillna(df['score'].mean(),inplace=True)
df['runtime'].fillna(df['runtime'].mean(),inplace=True)
df['budget'].fillna(df['budget'].mean(),inplace=True)
df['gross'].fillna(df['gross'].mean(),inplace=True)

#check data type
df.dtypes

df = df.sort_values(by=['gross'], inplace=False, ascending=False)

df.sort_values(by=['gross'], inplace=False, ascending=False)

# Are there any Outliers?
df.boxplot(column=['gross'])

#Budget high correlation, Company high correlation
#Scatter plot with budget vs gross
plt.scatter(x = df['budget'], y = df['gross'])
plt.title('Budget vs Gross')
plt.xlabel('budget')
plt.ylabel('gross')
plt.show()

df.head()

#there exists a positive correlation between budget and gross
sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color":"red"}, line_kws={"color":"blue"})

#looking at correlation by pearson method
df.corr(method='pearson')

#use heatmap to see the correlation
#high correlation between budget and gross is positive correlation = 0.750157
correlation_matrix = df.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title('correlation matric for numeric features')
plt.xlabel('movie features')
plt.ylabel('movie features')
plt.show()

#higher voted movies will have a higher gross earning
#Scatter plot with votes vs gross
plt.scatter(x = df['votes'], y = df['gross'])
plt.title('Votes vs Gross')
plt.xlabel('votes')
plt.ylabel('gross')
plt.show()

#there exists a positive correlation between gross and votes
sns.regplot(x='votes', y='gross', data=df, scatter_kws={"color":"red"}, line_kws={"color":"blue"})

#convert origina data to category data
df_numerized = df
for col_name in df_numerized.columns:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes

df_numerized

#compare data between original data and category data
df

#use heatmap to see the correlation
#vote and budget have the highest correlation to gross earnings
correlation_matrix = df_numerized.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True, fmt=".1g")
matplotlib.rcParams['figure.figsize'] = (12, 10)
plt.title('correlation matric for numeric features')
plt.xlabel('movie features')
plt.ylabel('movie features')
plt.show()

#distribution correlation of category data
df_numerized.corr()

#unstack value
correlation_mat = df_numerized.corr()
cor_pairs = correlation_mat.unstack()

cor_pairs

#sort correlation value = ascending
sorted_pairs = cor_pairs.sort_values()
sorted_pairs

#sort correlation > 0.5
#vote and budget have the highest correlation to gross earnings
high_corr = sorted_pairs[(sorted_pairs) > 0.5]
high_corr



