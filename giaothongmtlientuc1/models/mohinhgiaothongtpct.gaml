/***
* Name: khoitaotactu
* Author: Anh Dung
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model mophonggiaothong
global {
    geometry shape<-envelope(shape_file_roads);// view
    file shape_file_buildings <- file("../includes/nkBuildingSimple2.shp");
    file shape_file_roads <- file("../includes/nkRoadsSimple3/nkRoadsSimple3.shp");
    file shape_file_bounds <- file("../includes/bounds.shp");
    float step <- 1 #mn;
    
    int total_people -> {length (walk) + length (bus) + length (motobike) + length (car)};
    int time_total;
    //int nb_people <- 2;
    int nb_people_walk <- 100;
    int nb_people_bus <- 20;
    int nb_people_motobike <- 100;
    int nb_people_car <- 40;
    
    int nb_people_walk_in_traffic_jam -> {walk count (each.tatduong = true)};
    int nb_people_bus_in_traffic_jam -> {bus count (each.tatduong = true)};
    int nb_people_motobike_in_traffic_jam -> {motobike count (each.tatduong = true)};
    int nb_people_car_in_traffic_jam -> {car count (each.tatduong = true)};
    
    int nb_people_in_traffic_jam -> {nb_people_walk_in_traffic_jam + nb_people_bus_in_traffic_jam + nb_people_motobike_in_traffic_jam + nb_people_car_in_traffic_jam};
    
    // Kick co va toc do cac loai phuong tien
    float size_walk <- 5.0;
    float speed_walk <- 0.05;
    float size_bus <- 15.0;
    float speed_bus <- 0.3;
    float size_motobike <- 7.0;
    float speed_motobike <- 0.4;
    float size_car <- 10.0;
    float speed_car <- 0.5;
    
    int threshold_on_cell <- 10; // ngưỡng tắc đường, nếu số người trên 1 cell >= ngưỡng thì tắc đường, ngược lại đường thông thoáng có thể đi
    bool solution_traffic <- true;
    bool cell_broken <- false;
    bool cell_repair <- true;
    float prob_road_broken <- 0.00001;
    float prob_road_repair <- 0.001;
    float prob_comback <- 0.1 max: 1.0;
    float prob_continued <- 0.2 max: 1.0;
   
    
    
    graph the_graph;// graphicscho phép người lập hm tự do vẽ các hình dạng / hình học /văn bản mà không cần phải xác định loà
    init {
//    create building from: shape_file_buildings with: [type::string(read ("NATURE"))] {
//        if type="Industrial" {
//        color <- #blue ;
//        }
//    }
    create road from: shape_file_roads {
    	
    	ask cell overlapping self{
    		duongdi<-true;
    		color<-#black;
    	}
    	
    	
    }
    the_graph <- as_edge_graph(road);  
   
//    list<building> residential_buildings <- building;// where (each.type="Residential");
	create walk number: nb_people_walk {
        dichden <- any_location_in (one_of (road));
        location <- any_location_in (one_of (road));
    	//location <- any_location_in (one_of (cell where (each.duongdi = true)));
    	nha <- location;
    }
	create bus number: nb_people_bus {
        dichden <- any_location_in (one_of (road));
    	location <- any_location_in (one_of (road));
    	//location <- any_location_in (one_of (cell where (each.duongdi = true)));
    	nha <- location;
    }
    create motobike number: nb_people_motobike {
        dichden <- any_location_in (one_of (road));
    	location <- any_location_in (one_of (road));
    	//location <- any_location_in (one_of (cell where (each.duongdi = true)));
    	nha <- location;
    }
    create car number: nb_people_car {
        dichden <- any_location_in (one_of (road));
    	location <- any_location_in (one_of (road));
    	//location <- any_location_in (one_of (cell where (each.duongdi = true)));
    	nha <- location;
    }
     
}    
    
    reflex stop_simulation when: (total_people = 0) {
		do pause ;
	} 
    
}

species building {
    string type; 
    rgb color <- #gray  ;
    //Câu lệnh Aspect được sử dụng để xác định một cách để vẽ tác nhân hiện tại.
    aspect base {
    draw shape color: color ;
    }
}

species road skills: [skill_road] {
	
    rgb color <- #red ;
    
   
    aspect base {
    	draw shape color: color ;
    }
}


species people skills:[moving]{
    rgb color;
    float size;
    float speed;
    string vehicle;
    point dichden;
    point nha;
    string hanhvi;
	bool tatduong <- false;
	bool alert <- false;
	int weight <-0;
	int time_to_complete <- 0 update: time_to_complete + 1;
	int time_tatduong <- 0;
	
  	cell mycell;
  	cell last_cell <- mycell;
  	cell temp <- mycell;
  	//cell cell_dichden update: cell at dichden.location;
	//list<people> test update: people inside (mycell);// ds con nguoi có mat trong ô cùng ô hiện hành
	
	//list neighbors <- people where (each.location distance_to self.location < 1);
	bool at_leduong <- false;
	
	reflex update_time_tatduong when: tatduong = true {
		time_tatduong <- time_tatduong + 1;
	}
	

	reflex update_mycell {
		mycell <- cell at location;
		if (mycell.leduong){
			at_leduong <- true;
		}else{
			at_leduong <- false;
		}
	}
	
	reflex update_last_cell when: last_cell != temp and !tatduong{
		last_cell <- temp;
	}
	
    reflex dichuyen when: dichden != nil{
		//people agentA <- people closest_to(self);
		if (! tatduong){
			//do goto  on:(cell where (each.duongdi = true and each.broken = false)) target:dichden recompute_path: true speed:speed;// cell=true co duong =nil khong can thi di	
			do goto on: the_graph target:dichden recompute_path: true speed:speed;
			temp <- mycell;
		} else {
			if (solution_traffic) {
				if (hanhvi = "quaydau"){
       				dichden <- nha;
       				if (vehicle in ['motobike', 'walk']){
       					cell near <- one_of (mycell.neighbours_1 where (each.leduong = true or each.duongdi = true));
	       				//do goto on: the_graph target:dichden recompute_path: true speed:speed;
	       				do goto on:(cell where ((each.duongdi = true or each.leduong))) target:near recompute_path: true speed:speed;
       				}else {
       					cell near <- one_of (mycell.neighbours_1 where (each.duongdi = true));
	       				//do goto on: the_graph target:dichden recompute_path: true speed:speed;
	       				do goto on:(cell where ((each.duongdi = true))) target:near recompute_path: true speed:speed;
       				}	
        		}
        		if (hanhvi = "tieptuc"){
        			if (vehicle in ['motobike', 'walk']){
        				cell near <- one_of (mycell.neighbours_1 where (each.leduong = true or each.duongdi = true));
        				do goto on:(cell where ((each.leduong = true or each.duongdi))) target:near recompute_path: true speed:speed;	
        			}	
        		}	
			}
		}
    	
    	if(location = dichden){
    		//dichden <- any_location_in (one_of (road));
    		dichden <- nil;
        } 
             	
    }
    
    reflex speed_reduce {
    	list<people> near_people <- people where (each.location distance_to location < 2.0);
    	if (near_people != nil) {
    		alert <- true;
    	}
    }
    
    reflex statut_tatduong {
    	if (mycell.weight >= threshold_on_cell) {
    		tatduong <- true;
    	}else{
    		tatduong <- false;
    	}
    }
    
    reflex decide_comback when: ((tatduong = true or mycell.broken = true) and flip(prob_comback)) {
    	hanhvi <- "quaydau";
    }
    
    reflex decide_continued when: ((tatduong = true or mycell.broken = true) and flip(prob_continued)) {
    	hanhvi <- "tieptuc";
    }
    
    reflex refresh_hanhvi when: tatduong = false and at_leduong = false and mycell.broken = false {
    	hanhvi <- nil;
    }
    
    reflex disappear when: dichden = nil {
    	time_total <- time_total + time_to_complete;
    	do die;
    }
    
    aspect base {
  	  draw circle(size) color: color border: #black;
    }
}


species walk parent: people {
	string vehicle <- "walk";
	float size <- size_walk;
	float speed <- speed_walk;
	rgb color <- #yellow;
	int weight <- 1;
}

species bus parent: people {
	string vehicle <- "bus";
	float size <- size_bus;
	float speed <- speed_bus;
	rgb color <- #skyblue;
	int weight <- 6;
	point dichden <-any_location_in (one_of (road));
}

species motobike parent: people {
	string vehicle <- "motobike";
	float size <- size_motobike;
	float speed <- speed_motobike;
	rgb color <- #green;
	int weight <- 2;
}

species car parent: people {
	string vehicle <- "car";
	float size <- size_car;
	float speed <- speed_car;
	rgb color <- #red;
	int weight <- 3;
}


grid cell width:50 height:50 neighbors:8{
	bool duongdi <-false;
	bool leduong <- false;
	bool broken <- false;
	bool empty <- true;
	int weight <- 0;
	//road duong;
	//people connguoi;
	rgb color <- #white;
	list<walk> walk_on_cell update: walk inside (self);
	list<bus> bus_on_cell update: bus inside (self);
	list<motobike> motobike_on_cell update: motobike inside (self);
	list<car> car_on_cell update: car inside (self);
	list<cell> neighbours_1  <- (self neighbors_at 1);
	//int cd <- 0 update: length(people_on_cell);		
	
	aspect default{
		draw shape color:color;
	}
	
	reflex update_weight {
		weight <- walk_on_cell sum_of (each.weight) + bus_on_cell sum_of (each.weight) + motobike_on_cell sum_of (each.weight) + car_on_cell sum_of (each.weight);
	}
	
	reflex change_le {
		if(duongdi) {
			loop i over: neighbours_1 {
				if (! i.duongdi){
					ask i {
					leduong <- true;	
					color <- #blue;
					}	
				}
			}			
		}	
	}
	
	reflex road_broken when: cell_broken = true {
		if (duongdi = true and flip(prob_road_broken)){// tỷ lệ duong bị hư
			broken <- true;
			color <- #red;
		}
	}
	
	reflex road_repair when: cell_repair = true {
		if (broken and flip(prob_road_repair)){
			broken <- false;
			color <- #black;
		}
	}
	  
}

experiment giaothongtpct type: gui {
    parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
    parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;
    parameter "Shapefile for the bounds:" var: shape_file_bounds category: "GIS" ;
    
    parameter "Number of people walk:" var: nb_people_walk min:10 max:200 category: "Number of People" ;
    parameter "Number of people bus:" var: nb_people_bus min:10 max:200 category: "Number of People" ;
    parameter "Number of people motobike:" var: nb_people_motobike min:10 max:200 category: "Number of People" ;
    parameter "Number of people car:" var: nb_people_car min:10 max:200 category: "Number of People" ;
    
    /*
    parameter "Size of people:" var: size_walk category: "People";
    parameter "Speed of people:" var: speed_walk category: "People";
    parameter "Size of bus:" var: size_bus category: "People";
    parameter "Speed of bus:" var: speed_bus category: "People";
    parameter "Size of motobike:" var: size_motobike category: "People";
    parameter "Speed of motobike:" var: speed_motobike category: "People";
    parameter "Size of car:" var: size_car category: "People";
    parameter "Speed of car:" var: speed_car category: "People";
     */
    parameter "Probability to comback:" var: prob_comback category: "Each People";
    parameter "Probability to continued:" var: prob_continued category: "Each People";
    
    
    parameter "Solution traffic jam:" category:"Road" var: solution_traffic colors: [#blue, #lightskyblue];
    parameter "Threshold of people on cell:" var: threshold_on_cell category: "Road";
    parameter "Cell broken:" category:"Road" var: cell_broken colors: [#blue, #lightskyblue];
    parameter "Probability road broken:" var: prob_road_broken category: "Road";
    parameter "Cell repair:" category:"Road" var: cell_repair colors: [#blue, #lightskyblue];
    parameter "Probability road repair:" var: prob_road_repair category: "Road";
    
    
    output {
    display mophonggttpct type:opengl {
        species building aspect: base ;
        grid cell lines:#black;
        species road aspect: base ;
        species people aspect: base ;
        species walk aspect: base;
        species bus aspect: base;
        species motobike aspect: base;
        species car aspect: base;
    }   
     
    
    display People_tatduong refresh: every(1#cycles) {
		chart "Number people in traffic jam:" type: series size: {1,0.5} position: {0, 0} {
			data "number_of_people" value: nb_people_in_traffic_jam color: #blue ;
		}  
    }
    
    display "datalist_bar_cchart" refresh: every(1#cycles)  {
		chart "People_tatduong" type: histogram background: #lightgray {
			data "walk" value: walk count (each.tatduong = true) color: #blue;
			data "bus" value: bus count (each.tatduong = true) color: #red;
			data "motobike" value: motobike count (each.tatduong = true) color: #green;
			data "car" value: car count (each.tatduong = true) color: #blue;
		}
	}
    
    
    
    //monitor "Number of people:" value: total_people;
    //monitor "Number of people come back:" value: people count (each.hanhvi = "quaydau");
    //monitor "Number of people continued:" value: people count (each.hanhvi = "tieptuc");
    //monitor "Time:" value: time_total;   
    }
}
