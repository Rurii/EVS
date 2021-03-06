/**
 *  ElectionStd
 *  Author: arully
 *  Description: Standar Election
 */

model ElectionStd

import "../includes/var.gaml"
import "../includes/orde10.gaml"
//import "../includes/orde100.gaml"
//import "../includes/orde1000.gaml"
//import "../includes/orde100000.gaml"

global {
	/** Insert the global definitions, variables and actions here */
	bool debug1 <- false; bool debug2 <- false; bool debug3 <- false; bool debug4 <- false;
	
	int tot_actors <- nb_operator+nb_police+nb_party_witness+nb_observer;
	int n_cetak;
	
	/*
	 * gf: good factor; bf: bad factor
	 * bf -> utk pihak yg bs bersentuhan dg perhitungan & kotak suara = operator, police
	 * gf -> utk pihak yg menjadi saksi perhitungan & kotak suara = operator, police, PW, observer. 
	 *       Tp GF Operator masuk di nilai T=90 
	 */
	const bf_operator type: int <- 10 min: 1 max: 10 parameter: 'Operator Negativity:';
	const bf_police type: int <- 10 min: 1 max: 10 parameter: 'Operator Negativity:';
	const gf_police type: int <- 10 min: 1 max: 10 parameter: 'Police Positivity:';
	const gf_party_witness type: int <- 4 min: 1 max: 5 parameter: 'Party Witness Positivity:';
	const gf_observer type: int <- 2 min: 1 max: 5 parameter: 'Observer Positivity:';
	const pengurang_operator type: int <- 2 min: 1 max: 5 parameter: 'Operator Negativity:';
	const pengurang_police type: int <- 10 min: 1 max: 10 parameter: 'Police Negativity:';
	const pengurang_party_witness type: int <- 10 min: 1 max: 10 parameter: 'Party Witness Negativity:';
	const pengurang_observer type: int <- 10 min: 1 max: 20 parameter: 'Observer Negativity:';
	
	// int T;
	float trust;
	// int pengurang;
	
	list result_agents <- []; list operator_agents <- [];
	list<hasil> active_results; list<hasil> result_l2;
	
	/*
	 * T=sum(hadir_person)/sum(total_person)
	 */
	
	init {
		/* create tps number: nb_results; */
		create hasil number: nb_results returns: result_agents;
			ask result_agents {if debug1 {write "my name is " + name;do debug message: 'test';}}
		/* write "pengurang operator: " + pengurang_operator; */
		create operator number: nb_operator returns: operator_agents; 		
			ask operator_agents {if debug1 {write "pengurang: "+bf;}}
		create police number: nb_police;
		create party_witness number: nb_party_witness;
		create observer number: nb_observer;
	
		active_results <- list(copy(hasil));
		/* result_l2 <- list(copy(hasil)); */
		n_cetak <- nb_results;
	}
	
	reflex to_TPS {
		ask operator {do to_tps;}
		ask police {do to_tps;}
		ask party_witness {do to_tps;}
		ask observer {do to_tps;}
		ask hasil {
			//do penyesuaian;
		}
		
		ask hasil {
			do cetak; 
			if n_cetak = 1 {do cetak_batas; n_cetak <- nb_results;} else {n_cetak <- n_cetak-1;}
		}
		
	}
	
	reflex second_stage when: time = 50 {
		do tell message: "The second step begins !!!"; 
		do halt;
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
		int T <- 90;
		bool active <- true;
		bool l2 <- false;
		
		/* list<tps> my_tps; */
		// list<operator> my_operator; list<police> my_police; list<party_witness> my_party_witness; list<observer> my_observer;
		list official;
		//action kurangi {
		//	if (T>pengurang) {T <- T-pengurang;} else {pause}
		//}
		
		action bad (int value) {
			if (T>value) {T <- T-value;} else {halt}
		}
		action good (int value) {
			if (T<value) {T <- T+value;} else {halt}
		}
		action cetak {write ""+self+", "+T;} action cetak_batas {write "---\n";}
		
		reflex penyesuaian {
			if (official contains_any operator) {
			} else {if (T>wo_op) {do bad(wo_op);}}
			if (official contains_any police) {
			} else {write "pol "+self;if (T>wo_pol) {T <- T-wo_pol;}}
			if (official contains_any party_witness) {
			} else {write "pw "+self;if (T>wo_pw) {T <- T-wo_pw;}}
			if (official contains_any observer) {
			} else {write "ob "+self;if (T>wo_ob) {T <- T-wo_ob;}}
		}
	}
	
	species operator {
		int bf <- rnd(bf_operator);
		hasil my_hasil;
		bool in_tps <- false;

		init {
			my_hasil <- one_of (active_results where !(each.official contains_any operator));
			add self to: my_hasil.official;if debug4 {write "added "+my_hasil.official;}
		}
		
		action to_tps {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			// hasil my_hasil <- one_of (active_results where (each.my_operator = nil));
			//good tp ada warning// hasil my_hasil <- one_of (active_results where (empty(each.my_operator)));
			//my_hasil <- one_of (active_results where !(each.my_operator contains_any operator));
			//add self to: my_hasil.my_operator;write "added "+my_hasil.my_operator;
			//if my_hasil = nil {write "error";}
			//if my_hasil = nil {error ""+self;}
			if !in_tps {
				//my_hasil.pengurang <- self.pengurang;
				ask my_hasil {
					//perbaikan// do kurangi;tot_actors <- tot_actors-1;
					do bad(myself.bf);tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+myself.bf+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ""+self+", "+myself.bf+", "+T+", "+tot_actors+", "+official;}
				}
				in_tps <- true;
			}
		}
	}
	
	species police {
		int pengurang <- rnd(pengurang_police);
		hasil my_hasil;
		bool in_tps <- false;
		
		init{
			my_hasil <- one_of (active_results where !(each.official contains_any police));
			add self to: my_hasil.official;if debug4 {write "added "+my_hasil.official;}
		}
		action to_tps {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			//hasil my_hasil <- one_of (active_results where (each.my_police = nil));
			//if my_hasil = nil {write "error "+my_hasil;}
			if !self.in_tps {
				//my_hasil.pengurang <- self.pengurang;
				ask my_hasil {
					//perbaikan// do kurangi;tot_actors <- tot_actors-1;
					do bad(myself.pengurang);tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+myself.pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ""+self+", "+myself.pengurang+", "+T+", "+tot_actors+", "+official;}
				}
				self.in_tps <- true;
			}
		}
	}
	
	species party_witness {
		int pengurang <- rnd(pengurang_party_witness);
		hasil my_hasil;
		bool in_tps <- false;
		
		init{
			my_hasil <- one_of (active_results where !(each.official contains_any party_witness));
			add self to: my_hasil.official;if debug4 {write "added "+my_hasil.official;}
		}
		action to_tps {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			//hasil my_hasil <- one_of (active_results where (each.my_party_witness = nil));
			//if my_hasil = nil {write "error";}
			if !in_tps {
				//my_hasil.pengurang <- self.pengurang;
				ask my_hasil {
					//perbaikan// do kurangi;tot_actors <- tot_actors-1;
					do bad(myself.pengurang);tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+myself.pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ""+self+", "+myself.pengurang+", "+T+", "+tot_actors+", "+official;}
				}
				in_tps <- true;
			}
		}
	}
	
	species observer {
		int pengurang <- rnd(pengurang_observer);
		hasil my_hasil;
		bool in_tps <- false;
		
		init{
			my_hasil <- one_of (active_results where !(each.official contains_any observer));
			add self to: my_hasil.official;if debug4 {write "added "+my_hasil.official;}
		}
		action to_tps {
			// ada yg lebih baik di bawah // hasil my_hasil <- one_of (active_results where (each.my_operator != nil));
			//hasil my_hasil <- first_with (active_results where (each.my_operator != nil));
			//hasil my_hasil <- one_of (active_results where (each.my_observer = nil));
			//if my_hasil = nil {write "error";}
			if !in_tps {
				//my_hasil.pengurang <- self.pengurang;
				ask my_hasil {
					//perbaikan// do kurangi;tot_actors <- tot_actors-1;
					do bad(myself.pengurang);tot_actors <- tot_actors-1;
					if debug2 {write "nama: "+name+" pengurang: "+myself.pengurang+" T: "+T+" Actors: "+tot_actors;}
					if debug3 {write ""+self+", "+myself.pengurang+", "+T+", "+tot_actors+", "+official;}
				}
				in_tps <- true;
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
	parameter name: 'Number of Poll Station' var: nb_results init: 57;
	parameter name: 'Number of Operator' var: nb_operator init: 57;
	parameter name: 'Number of Police' var: nb_police init: 50;
	parameter name: 'Number of Party Witness ' var: nb_party_witness init: 50;
	parameter name: 'Number of Observer' var: nb_observer init: 50;
	
 	reflex info_sim{
		write "Running a new simulation " + simulation;
	} 

	/* permanent { */
	output { 
		display ElectionStd background: rgb('white') refresh_every: 1 {
			chart "Trustworthiness" type: series {
				data "Trustwortiness" value: trust;
			}
		}
	} 
	
	
}