#!/usr/bin/env ruby
require 'json'
require 'optparse'
class Evolution
    # configuration = hash of knapsack conf
    def initialize(configuration, 
                generations,
                populationSize,
                genomSize,
                xoverProbability,
                tournamentCount,
                tournamentSize,
                elitismRatio,
                mutationRate,
                options
                )
        @configuration = configuration
        @items = configuration[:items]
        @capacity = configuration[:capacity] 
        @generations = generations
        @populationSize = populationSize
        @genomSize = genomSize
        @xoverProbability = xoverProbability
        @tournamentCount = tournamentCount
        @tournamentSize = tournamentSize
        @elitismRatio = elitismRatio
        @mutationRate = mutationRate
        @population = []
        @options = options
    end

    def createIndividual(genomSize)
        return Array.new(genomSize) { rand(2) }
    end
    
    def createPopulation(populationSize, genomSize)
        return Array.new(populationSize) { createIndividual(genomSize) }
    end
    
    def randomIndividual(population)
        return population[rand(population.size)].clone
    end
    
    def getFitness(individual)
        value = 0
        weight = 0
        individual.each_with_index do |item, index|
            if item
                value = value + @items[index][:price]
                weight = weight + @items[index][:weight]
            end
        end
        if weight <= @capacity
            return value
        else
            return 0
        end
    end

    def sortByFitness(population) 
        return population.sort_by{ |individual| getFitness(individual) }.reverse
    end

    def checkWeight(individual) 
        weight = 0
        individual.each_with_index do |item, index|
            weight = weight + @items[index][:weight] if item
        end
        return weight <= @capacity
    end

    def tournament(tournamentCount, tournamentSize) 
        selected = []
        tournamentCount.times do |i| 
            bestScore = -1;
            champion = []
            # champion[0] = @population[0].clone;
            # champion[1] = @population[0].clone;
            champion = randomIndividual(@population)
            # champion[1] = randomIndividual(@population)

            # 2.times do |champNo|
                tournamentSize.times do 
                    player = randomIndividual(@population)
                    if getFitness(player) > bestScore
                        champion = player.clone
                        # champion[champNo] = player.clone
                        bestScore = getFitness(player)
                    end
                end
            # end
            # maxChampion = getFitness(champion[0]) > getFitness(champion[1]) ? champion[0] : champion[1]
            maxChampion = champion
            # puts "Champion: #{maxChampion}" if @options[:verbose]
            selected << maxChampion;
        end
        # puts "Tournament:" 
        # jj selected if @options[:verbose]
        selected
    end

    def crossover(i1, i2)
        result = Array.new(2){[]}
        x = rand(@genomSize)
        (0..x).each do |i|
            result[0][i] = i1[i]
            result[1][i] = i2[i]
        end
        (x..@genomSize).each do |i| 
            result[0][i] = i2[i]
            result[1][i] = i1[i]
        end
        result
    end

    def mutate(individual) 
        @genomSize.times do |i| 
            individual[i] = !individual[i] if @mutationRate <= rand()
        end
    end

    def run
        bestFitness = 0
        @population = createPopulation(@populationSize, @genomSize);
        
        for generation in (0..@generations)
            sorted = sortByFitness(@population)
            
            bestFitness = getFitness(@population[0])
            File.write("#{@options[:outputFile]}", "#{generation},#{bestFitness}\n", mode: 'a') unless @options[:outputFile].nil?
            if @options[:verbose]
                puts "Generation #{generation}: best fitness - #{bestFitness}" 
                # puts "Best: #{@population[0]}"
                # puts "Worst: #{@population[@population.size-1]}"
            end
            #elite
            sorted = sorted[0..@elitismRatio*@populationSize]
            #tournament
            newPopulation = tournament(@tournamentCount, @tournamentSize)
            
            newPopulation = newPopulation + sorted
            # sorted = sortByFitness(sorted)

            while newPopulation.size != @populationSize
                childs = Array.new(2){[]}
                #crossover
                if (@xoverProbability <= rand())
                    i1 = randomIndividual(sorted)
                    i2 = randomIndividual(sorted)
                    childs = crossover(i1,i2)
                else
                    2.times {|i| childs[i] = randomIndividual(sorted) }
                end
                #mutate
                childs.each do |child|
                    mutate(child)
                    # check if mutated is in constrains
                    newPopulation << child if checkWeight(child) && newPopulation.size < @populationSize
                end
            end
            @population = newPopulation.clone
            @population = sortByFitness(@population)
        end
        result = {
            :items => @population[0],
            :price => getFitness(@population[0])
        }
        return result
    end
end
# return hash with array and price
def findInstanceSolution(instance, filename) 
    result = {}
    File.readlines(filename).each do |line|
        next unless line.match(instance)
        tmp_arr = line.split(' ')
        result[:price] = tmp_arr[2]
        result[:items] = tmp_arr[3..tmp_arr.size]
        return result
    end 
end

def computeRelativeError(optimum, approx)
    return (optimum-approx).to_f / optimum.to_f
end

options = {
    :verbose => false
}
OptionParser.new do |opt|
    opt.on('-v','--verbose') { options[:verbose] = true }
    opt.on('-f','--file FILENAME') { |o| options[:filename] = o }
    opt.on('-c','--control-file FILENAME') { |o| options[:check_file] = o }
    opt.on('--generations NUMBER') { |o| options[:generations] = o.to_i }
    opt.on('--populationSize NUMBER') { |o| options[:populationSize] = o.to_i }
    opt.on('--tournamentCount NUMBER') { |o| options[:tournamentCount] = o.to_i }
    opt.on('--tournamentSize NUMBER') { |o| options[:tournamentSize] = o.to_i }
    opt.on('--xoverProbability NUMBER') { |o| options[:xoverProbability] = o.to_f }
    opt.on('--elitismRatio NUMBER') { |o| options[:elitismRatio] = o.to_f }
    opt.on('--mutationRate NUMBER') { |o| options[:mutationRate] = o.to_f }
    opt.on('-o','--output FILE') { |o| options[:outputFile] = o }
    opt.on('-n','--count COUNT') { |o| options[:count] = o.to_i }
end.parse!

jj options if options[:verbose]

FILE_NAME = options[:filename]
cnt = 0;
File.readlines(FILE_NAME).each do |line |
    break if !options[:count].nil? && cnt >= options[:count]
    cnt = cnt + 1
    instance = line.split(' ')
    configuration = {
        :instance => instance[0],
        :capacity => instance[2].to_i,
        :items => []
    }
    i =0
    index = 0
    while index < instance[1].to_i
        configuration[:items][index]= {}
        configuration[:items][index][:weight] = instance[i+3].to_i
        configuration[:items][index][:price] = instance[i+1+3].to_i
        i = i + 2
        index = index + 1
    end
    evolOptions = {
        :outputFile => options[:outputFile],
        :verbose => options[:verbose]
    }
    genomSize = configuration[:items].size
    e = Evolution.new(configuration,
        options[:generations],
        options[:populationSize],
        genomSize,
        options[:xoverProbability],
        options[:tournamentCount],
        options[:tournamentSize],
        options[:elitismRatio],
        options[:mutationRate],
        evolOptions
        );
    bestFitness = e.run()
    optimum = findInstanceSolution(configuration[:instance], options[:check_file])[:price].to_i
    approx = bestFitness[:price]
    puts "#{configuration[:instance]} #{computeRelativeError(optimum, approx)}"
    # puts "\t#{findInstanceSolution(configuration[:instance], options[:check_file])[:price]}"
    # puts "\t#{bestFitness[:price]}"
end

