#!/bin/sh 
run_genetic() {
    params=$@
    src/GeneticSolver.rb -f data/knap_30.inst.dat -c solution/knap_30.sol.dat \
    --generations $1 \
    --populationSize $2 \
    --tournamentCount $3 \
    --tournamentSize $3 \
    --xoverProbability $5 \
    --elitismRatio $6 \
    --mutationRate $7 -n1 -o report/csv/$8.csv > report/csv/run_all_${params//' '/_}.csv
}

for folder in xoverProbability mutationRate elitismRatio tournamentCount tournamentSize; do
    rm -r report/csv 2>/dev/null
    mkdir -p report/csv/${folder}
done
echo xoverProbability 
for xoverProbability in 0.1 0.2 0.3 0.4 0.5 0.6 0.8; do
    echo -n "${xoverProbability} "
	run_genetic 1000 100 20 10 $xoverProbability 0.1 0.4 xoverProbability_${xoverProbability}
done

echo mutationRate 
# for mutationRate in 0.01 0.025 0.05 0.1 0.15 0.2 0.3; do
for mutationRate in 0.1 0.2 0.3 0.4 0.5 0.6 0.8; do
    echo -n "${mutationRate} "
	run_genetic 1000 100 20 10 0.4 0.1 $mutationRate mutationRate_$mutationRate
done

echo elitismRatio 
for elitismRatio in 0.05 0.1 0.2 0.25 0.3 0.35 0.4 ; do
    echo -n "${elitismRatio} "
	run_genetic 1000 100 20 10 0.4 $elitismRatio 0.4 elitismRatio_$elitismRatio
done

echo tournamentCount 
for tournamentCount in 1 2 5 10 16 20 40 50; do
    echo -n "${tournamentCount} "
	run_genetic 1000 100 $tournamentCount 10 0.4 0.1 0.4 tournamentCount_$tournamentCount
done

echo tournamentSize
for tournamentSize in 1 2 5 10 16 20 40 50; do
    echo -n "${tournamentSize} "
	run_genetic 1000 100 20 $tournamentSize 0.4 0.1 0.4 tournamentCount_$tournamentSize
done