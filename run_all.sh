#!/bin/sh 
for folder in xoverProbability mutationRate elitismRatio tournamentCount tournamentSize; do
    rm -r report/csv 2>/dev/null
    mkdir -p report/csv/${folder}
done
echo xoverProbability 
for xoverProbability in 0.1 0.2 0.3 0.4 0.5 0.6 0.8; do
    echo -n "${xoverProbability} "
	src/GeneticSolver.rb -f data/knap_30.inst.dat -c solution/knap_30.sol.dat \
    --generations 1000 \
    --populationSize 100 \
    --tournamentCount 20 \
    --tournamentSize 10 \
    --xoverProbability ${xoverProbability} \
    --elitismRatio 0.1 \
    --mutationRate 0.4 -n1 -o report/csv/xoverProbability_${xoverProbability}.csv
done

echo mutationRate 
# for mutationRate in 0.01 0.025 0.05 0.1 0.15 0.2 0.3; do
for mutationRate in 0.1 0.2 0.3 0.4 0.5 0.6 0.8; do
    echo -n "${mutationRate} "
    src/GeneticSolver.rb -f data/knap_30.inst.dat -c solution/knap_30.sol.dat \
    --generations 1000 \
    --populationSize 100 \
    --tournamentCount 20 \
    --tournamentSize 10 \
    --xoverProbability 0.4 \
    --elitismRatio 0.1 \
    --mutationRate ${mutationRate} -n1 -o report/csv/mutationRate_${mutationRate}.csv
done

echo elitismRatio 
for elitismRatio in 0.05 0.1 0.2 0.25 0.3 0.35 0.4 ; do
    echo -n "${elitismRatio} "
    src/GeneticSolver.rb -f data/knap_30.inst.dat -c solution/knap_30.sol.dat \
    --generations 1000 \
    --populationSize 100 \
    --tournamentCount 20 \
    --tournamentSize 10 \
    --xoverProbability 0.4 \
    --elitismRatio ${elitismRatio} \
    --mutationRate 0.4 -n1 -o report/csv/elitismRatio_${elitismRatio}.csv
done

echo tournamentCount 
for tournamentCount in 1 2 5 10 16 20 40 50; do
    echo -n "${tournamentCount} "
    src/GeneticSolver.rb -f data/knap_30.inst.dat -c solution/knap_30.sol.dat \
    --generations 1000 \
    --populationSize 100 \
    --tournamentCount ${tournamentCount} \
    --tournamentSize 10 \
    --xoverProbability 0.4 \
    --elitismRatio 0.1 \
    --mutationRate 0.4 -n1 -o report/csv/tournamentCount_${tournamentCount}.csv
done

echo tournamentSize
for tournamentSize in 1 2 5 10 16 20 40 50; do
    echo -n "${tournamentSize} "
    src/GeneticSolver.rb -f report/csv/knap_30.inst.dat -c solution/knap_30.sol.dat \
    --generations 1000 \
    --populationSize 100 \
    --tournamentCount 20 \
    --tournamentSize ${tournamentSize} \
    --xoverProbability 0.4 \
    --elitismRatio 0.1 \
    --mutationRate 0.4 -n1 -o report/csv/tournamentSize_${tournamentSize}.csv
done