/***
* Name: khoitaotactu
* Author: Anh Dung
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model khoitaotactu
global {
    geometry shape<-envelope(shape_file_roads);// view
    file shape_file_buildings <- file("../includes/nkBuildingSimple2.shp");
    file shape_file_roads <- file("../includes/roads_sample.shp");
    file shape_file_bounds <- file("../includes/bounds.shp");
    float step <- 1 #mn;
    int nb_people <- 2;
    int total_people -> {length (people)};
    
    
    
    int threshold_on_cell <- 4; // ngưỡng tắc đường, nếu số người trên 1 cell >= ngưỡng thì tắc đường, ngược lại đường thông thoáng có thể đi
    bool solution_traffic <- false;
    float prob_road_broken <- 0.00001;
    float prob_road_repair <- 0.001;
    
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
    create people number: nb_people {
        dichden <- any_location_in (one_of (road));
    	location <- any_location_in (one_of (road));
    	nha <- location;
    	}
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

species road  {
	string name;
	string id;
	int loaiduong;
	
    rgb color <- #black ;
    
   
    aspect base {
    draw shape color: color ;
    }
}

species people skills:[moving]{
    rgb color <- #yellow ;
    string hoten;
    string dc;
    string nghenghiep;
    point dichden;
    point nha;
    string hanhvi;
	
	
  	cell mycell;
	list<people> test update: people inside (mycell);// ds con nguoi có mat trong ô cùng ô hiện hành
	//list neighbors <- people where (each.location distance_to self.location < 1);
	
	
	reflex update_mycell {
		mycell <- cell at location;
	}
  	
    reflex dichuyen when: dichden != nil{
    	bool tatduong <- false; // chua tat duong
    	if (mycell.cd >= threshold_on_cell) {
    		tatduong <- true;
    	}
		
		if (! tatduong){
    		do goto  on:(cell where (each.duongdi = true and each.broken = false)) target:dichden speed:0.01;// cell=true co duong =nil khong can thi di
		} else {
			if (solution_traffic) {
				int rand <- rnd(1); // gia su 0 la quay dau, 1 la tieptuc
				switch rand {
					match 0 {
						hanhvi <- "quaydau";
					}
					match 1 {
						hanhvi <- "tieptuc";
					}
				}
				if (hanhvi = "quaydau"){
       				dichden <- nha;	
        		}
        		if (hanhvi = "tieptuc"){
        			do goto on:(cell where ((each.leduong = true or each.duongdi = true))) target:dichden speed:0.01;		
        		}	
			}
		}
    	
    	if(location distance_to dichden<1){
    		//dichden <- any_location_in (one_of (road));
    		dichden <- nil;
        }
        
        	
    }
    
    reflex disappear when: dichden = nil {
    	do die;
    }
    
    aspect base {
  	  draw circle(0.5) color: color border: #black;
    }
}

grid cell width:50 height:50 neighbors:8{
	bool duongdi <-false;
	bool leduong <- false;
	bool broken <- false;
	//road duong;
	//people connguoi <- nil;
	rgb color <- #white;
	list<people> people_on_cell update: people inside (self);
	list<cell> neighbours_1  <- (self neighbors_at 1);
	int cd <- 0 update: length(people_on_cell);		
	
	aspect default{
		draw shape color:color;
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
	
	reflex road_broken {
		if (duongdi = true and flip(prob_road_broken)){// tỷ lệ duong bị hư
			broken <- true;
			color <- #red;
		}
	}
	
	reflex road_repair {
		if (broken and flip(prob_road_repair)){
			broken <- false;
			color <- #black;
		}
	}
	  
}

experiment khoitaotactu type: gui {
    parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
    parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;
    parameter "Shapefile for the bounds:" var: shape_file_bounds category: "GIS" ;
    
    parameter "Number of people agents" var: nb_people category: "People" ;
    
    parameter "Solution traffic jam:" category:"Road" var: solution_traffic colors: [#blue, #lightskyblue];
    parameter "Threshold of people on cell:" var: threshold_on_cell category: "Road";
    parameter "Probability road broken:" var: prob_road_broken category: "Road";
    parameter "Probability road repair:" var: prob_road_repair category: "Road";
    
    
    
    output {
    display khotaitt type:opengl {
        species building aspect: base ;
        grid cell lines:#black;
        species road aspect: base ;
        species people aspect: base ;
    }
    
    monitor "Number of people:" value: total_people;
    monitor "Number of people come back:" value: people count (each.hanhvi = "quaydau");
    monitor "Number of people continued:" value: people count (each.hanhvi = "tieptuc");
    
    }
}
