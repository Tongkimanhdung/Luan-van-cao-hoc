/**
* Name:  Model using Batch mode
* Author:  Patrick Taillandier
* Description: A model showing how to use batch experiments to find the best combination of parameters to minimize the numbers of infected people 
*      in a SIR infection model where agents infect others and become immune for a certain time. The batch mode uses three different methods : Exhaustive, 
*      GA and Tabu Search. The model proposes five experiments : one simple with a User Interface, one running 5 experiments and saving the data, and one 
*      for each strategy. 
* Tags: batch, algorithm, save_file
*/

model khoitaotactu

import "./khoitaotactu.gaml"

// This experiment explores two parameters with an exhaustive strategy,
// repeating each simulation three times (the aggregated fitness correspond to the mean fitness), 
// in order to find the best combination of parameters to minimize the number of infected people

experiment 'Exhaustive optimization (number people in traffic jam)' type: batch repeat: 5 keep_seed: true until: (total_people =0 or time > 200) {
	parameter 'Weight in cell:' var: threshold_on_cell min:6 max: 10 step: 1;
	parameter 'Prob to comback:' var: prob_comback min: 0.1 max: 0.5 step: 0.1;
	parameter 'Prob to continued:' var: prob_continued min: 0.1 max: 0.5 step: 0.1;
	
	method exhaustive minimize: nb_people_in_traffic_jam; 	
	//the permanent section allows to define a output section that will be kept during all the batch experiment
	permanent {
		display Comparison {
			chart "Total people" type: series {
				//we can access to all the simulations of a run (here composed of 5 simulation -> repeat: 5) by the variable "simulations" of the experiment.
				//here we display for the 5 simulations, the mean, min and max values of the nb_infected variable.
				data "Mean" value: mean(simulations collect each.nb_people_in_traffic_jam ) style: spline color: #blue ;
				data "Min" value:  min(simulations collect each.nb_people_in_traffic_jam ) style: spline color: #darkgreen ;
				data "Max" value:  max(simulations collect each.nb_people_in_traffic_jam ) style: spline color: #red ;
			}
		}	
	}
}


/*
experiment 'Exhaustive optimization (population)' type: batch repeat: 2 keep_seed: true until: ( time > 400 or nb_predators = 0 or nb_preys = 0 ) {
	//parameter 'Prey number init' var: number_preys_init among: [50, 100, 200];
	parameter "Prey max transfert:" var: prey_max_transfer min: 0.05 max: 0.5 step: 0.1 ;
	parameter "Prey energy reproduce:" var: prey_energy_reproduce min: 0.05 max: 0.75 step: 0.3;
	parameter "Predator energy transfert:" var: predator_max_transfer min: 0.1 max: 1.0 step: 0.5 ;
	parameter "Predator energy reproduce:" var: predator_energy_reproduce min: 0.1 max: 1.0 step: 0.5;
	method exhaustive maximize: nb_preys + nb_predators aggregation: "max";
	 	
	//the permanent section allows to define a output section that will be kept during all the batch experiment
	permanent {
		display Comparison {
			chart "Total Food Energy" type: series {
				//we can access to all the simulations of a run (here composed of 5 simulation -> repeat: 5) by the variable "simulations" of the experiment.
				//here we display for the 5 simulations, the mean, min and max values of the nb_infected variable.
				data "Mean" value: mean(simulations collect each.nb_preys) style: spline color: #blue ;
				data "Min" value:  min(simulations collect each.nb_preys ) style: spline color: #darkgreen ;
				data "Max" value:  max(simulations collect each.nb_preys ) style: spline color: #red ;
			}
		}	
	}
}


experiment Tabu_Search type: batch keep_seed: true repeat: 3 until: ( time > 400 ) {
	parameter "Prey max transfert:" var: prey_max_transfer min: 0.05 max: 0.5 step: 0.1 ;
	parameter "Prey energy reproduce:" var: prey_energy_reproduce min: 0.05 max: 0.75 step: 0.3;
	parameter "Predator energy transfert:" var: predator_max_transfer min: 0.1 max: 1.0 step: 0.5 ;
	parameter "Predator energy reproduce:" var: predator_energy_reproduce min: 0.1 max: 1.0 step: 0.5;
	method tabu iter_max: 50 tabu_list_size: 3 minimize: nb_preys + nb_predators aggregation: "max";
}

experiment Genetic type: batch keep_seed: true repeat: 3 until: ( time > 1000 ) {
	//parameter 'Prey proba reproduce' var: prey_proba_reproduce among: [ 0.01 , 0.015 , 0.02 ];
	//parameter 'Prey proba sick' var: species_proba_sick among: [0.001, 0.002];
	//parameter 'Rate of food growth:' var: food_growth among: [0.01, 0.05, 0.1];
	//parameter 'Infection rate' var: infection_rate among: [ 0.1 ,0.2, 0.5 , 0.6,0.8, 1.0 ];
	//parameter 'Speed of people:' var: speed_people min: 1.0 max: 10.0 step:1.0;
	
	parameter "Prey max transfert:" var: prey_max_transfer min: 0.05 max: 0.5 step: 0.1 ;
	parameter "Prey energy reproduce:" var: prey_energy_reproduce min: 0.05 max: 0.75 step: 0.3;
	parameter "Predator energy transfert:" var: predator_max_transfer min: 0.1 max: 1.0 step: 0.5 ;
	parameter "Predator energy reproduce:" var: predator_energy_reproduce min: 0.1 max: 1.0 step: 0.5;

	
	method genetic pop_dim: 3 crossover_prob: 0.7 mutation_prob: 0.1 improve_sol: true stochastic_sel: false
	nb_prelim_gen: 1 max_gen: 5  maximize: nb_preys + nb_predators  aggregation: "min";
}

experiment HillClimbing type: batch repeat: 3 keep_seed: true until: ( time > 400 or nb_predators = 0 or nb_preys = 0 ) {
	parameter "Prey max transfer:" var: prey_max_transfer min: 0.05 max: 0.5 step: 0.1 ;
	parameter "Prey energy reproduce:" var: prey_energy_reproduce min: 0.05 max: 0.75 step: 0.3;
	parameter "Predator energy transfert:" var: predator_max_transfer min: 0.1 max: 1.0 step: 0.5 ;
	parameter "Predator energy reproduce:" var: predator_energy_reproduce min: 0.1 max: 1.0 step: 0.5;
    method hill_climbing iter_max: 50 maximize: nb_preys + nb_predators;  
}
* 
*/