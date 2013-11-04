/**
 *  ElectionStd
 *  Author: arully
 *  Description: Standar Election
 */

model ElectionStd

global {
	/** Insert the global definitions, variables and actions here */
	bool debug1 <- false; bool debug2 <- false; bool debug3 <- true;
	int nb_operator <- 57;
	int nb_police <- 50;
	int nb_party_witness <- 37;
	int nb_observer <- 27;
	int nb_results <- 57;
	int tot_actors <- nb_operator+nb_police+nb_party_witness+nb_observer;
	
	const pengurang_operator type: int <- 2 min: 1 max: 5 parameter: 'Pengaruh Negatif Operator:';
	const pengurang_police type: int <- 10 min: 1 max: 10 parameter: 'Pengaruh Negatif Police:';
	const pengurang_party_witness type: int <- 10 min: 1 max: 10 parameter: 'Pengaruh Negatif Party Witness:';
	const pengurang_observer type: int <- 10 min: 1 max: 20 parameter: 'Pengaruh Negatif Observer:';
	
	// int T;
	float trust;
	// int pengurang;
	
	list result_agents <- [];
	list operator_agents <- [];
	
	list<hasil> active_results;
	list<hasil> result_l2;
	/* list<tps> active_tps; */
	
	/*
	 * T=sum(hadir_person)/sum(total_person)
	 */
	
	init {
		/* create tps number: nb_results; */
		create hasil number: nb_results returns: result_agents;
			ask result_agents {if debug1 {write "my name is " + name;do debug message: 'test';}}
		/* write "pengurang operator: " + pengurang_operator; */
		create operator number: nb_operator returns: operator_agents; 		
			ask operator_agents {if debug1 {write "pengurang: "+pengurang;}}
		create police number: nb_police;
		create party_witness number: nb_party_witness;
		create observer number: nb_observer;
	
		active_results <- list(copy(hasil));
		/* result_l2 <- list(copy(hasil)); */
	}
	
	reflex dynamic {
		ask operator {do moving;}
		ask police {do moving;}
		ask party_witness {do moving;}
		ask observer {do moving;}
		
		
		
		
	}
	
	
	reflex calculate_trust {
		trust <- 0.0;
		// float abst <- (nb_results - sum (active_results collect (length(each.my_operator)))) / nb_results;
		trust <- ( sum(active_results collect(each.T)) / nb_results ) / 100;
		//trust <- sum(active_results collect(each.T));
	}	
	
	// reflex kill_sim when: (tot_actors=0) {do halt;}
	
	/*
	reflex kill_sim {
		if 
	}
	
	*/
}

entities {
	/* species tps {} */
	species hasil {
		int T <- 100;
		int pengurang;
		bool active <- true;
		bool l2 <- false;
		
		/* list<tps> my_tps; */
		list<operator> my_operator; police my_police; party_witness my_party_witness; observer my_observer;
		action kurangi {
			if (T>pengurang) {T <- T-pengurang;} else {pause}
		}
	}
	
	species operator {
		int pengurang <- rnd(pengurang_operator);
		hasil my_hasil;
		bool is_tps <- false;
		
		init {
			hasil my_hasil <- one_of (active_results where !(each.my_operator contains_any operator));
			if my_hasil = nil {write "error";}
			add self to: my_hasil.my_operator;write "added "+my_hasil.my_operator;
			my_hasil.pengurang <- self.pengurang;
			if !is_tps {
				ask my_hasil {
					//add self to: my_hasil.my_operator;
					do kurangi;tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ":: "+self+", "+pengurang+", "+T+", "+tot_actors+", "+my_operator;}
				}
				is_tps <- true;
			}
		}
		
		action moving{
			write "moving";
			//write "MOVED "+my_hasil+" "+my_hasil.my_operator;
		}

/*		
		action moving {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			// hasil my_hasil <- one_of (active_results where (each.my_operator = nil));
			//good tp ada warning// hasil my_hasil <- one_of (active_results where (empty(each.my_operator)));
			//hasil my_hasil <- one_of (active_results where (each.my_operator contains_any operator));
			add self to: my_hasil.my_operator;write "added "+my_hasil.my_operator;
			//if my_hasil = nil {write "error";}
			//if my_hasil = nil {error ""+self;}
			my_hasil.pengurang <- self.pengurang;
			if !is_tps {
				ask my_hasil {
					//add self to: my_hasil.my_operator;
					do kurangi;tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ":: "+self+", "+pengurang+", "+T+", "+tot_actors+", "+my_operator;}
				}
				is_tps <- true;
			}
		}
*/

	}
	
	species police {
		int pengurang <- rnd(pengurang_police);
		hasil my_hasil;
		bool is_tps <- false;
		
		action moving {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			hasil my_hasil <- one_of (active_results where (each.my_police = nil));
			if my_hasil = nil {write "error "+my_hasil;}
			my_hasil.pengurang <- self.pengurang;
			if !self.is_tps {
				ask my_hasil {
					do kurangi;tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+my_hasil+" pengurang: "+pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ""+my_hasil+", "+pengurang+", "+T+", "+tot_actors;}
				}
				self.is_tps <- true;
			}
		}
	}
	
	species party_witness {
		int pengurang <- rnd(pengurang_party_witness);
		hasil my_hasil;
		bool is_tps;
		
		action moving {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			hasil my_hasil <- one_of (active_results where (each.my_party_witness = nil));
			if my_hasil = nil {write "error";}
			my_hasil.pengurang <- self.pengurang;
			if !is_tps {
				ask my_hasil {
					do kurangi;tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ""+my_hasil+", "+pengurang+", "+T+", "+tot_actors;}
				}
				is_tps <- true;
			}
		}
	}
	
	species observer {
		int pengurang <- rnd(pengurang_observer);
		hasil my_hasil;
		bool is_tps;
		
		action moving {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			hasil my_hasil <- one_of (active_results where (each.my_observer = nil));
			if my_hasil = nil {write "error";}
			my_hasil.pengurang <- self.pengurang;
			if !is_tps {
				ask my_hasil {
					do kurangi;tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ""+my_hasil+", "+pengurang+", "+T+", "+tot_actors;}
				}
				is_tps <- true;
			}
		}
	}
	
}


experiment ElectionStd type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display ElectionStd background: rgb('white') refresh_every: 1 {
			chart "Trustworthiness" type: series {
				data "Trustwortiness" value: trust;
			}
		}
	}
}

/* experiment Batch type: batch repeat: 2 keep_seed: true until: (food_gathered = food_placed) or (time > 400) { */
experiment Batch type: batch repeat: 2 keep_seed: true until: (time > 100) {
	parameter name: 'Number of Operator' var: nb_operator init: 57;
	parameter name: 'Number of Police' var: nb_police init: 50;
	parameter name: 'Number of Party Witness ' var: nb_party_witness init: 50;
	parameter name: 'Number of Observer' var: nb_observer init: 50;
	
/* 	reflex info_sim{
		write "Running a new simulation " + simulation;
	} */

	
	permanent {
		display ElectionStd background: rgb('white') refresh_every: 1 {
			chart "Trustworthiness" type: series {
				data "Trustwortiness" value: trust;
			}
		}
	}
	
	
}