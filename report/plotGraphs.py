#!/usr/bin/env python3
import matplotlib.pyplot as Pyplot
import numpy as Numpy
import pandas as Pandas
import os
from os import listdir
from os.path import isfile, join

csv_path = 'csv'
# get list of files
only_files = [f for f in listdir(csv_path) if isfile(join(csv_path, f))]
for csv in only_files:
    first_line = ''
    with open(join(csv_path,csv)) as f:
        first_line = f.readline()
    first_col=first_line.split(',')[0]
    second_col=first_line.split(',')[1]
    print(join(csv_path,csv))
    data_file = Pandas.read_csv(join(csv_path,csv), index_col=first_col)
    Pyplot.figure()
    Pyplot.xlabel(first_col.title())
    Pyplot.ylabel(second_col.title())
    plot_title = csv.split('/')[-1].strip('.csv').replace('_',' = ')
    Pyplot.title(f'{second_col.title()} developement with {plot_title}')
    Pyplot.plot(data_file)
    Pyplot.savefig(join('png',csv.replace('.csv','.png')))
    # Pyplot.show()
