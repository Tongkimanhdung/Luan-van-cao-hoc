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
    
    reflex dichuyen{
//    	do goto  on:the_graph target:dichden speed:0.01;
		cell c<-cell at location;
		c.connguoi<-nil;
    	do goto  on:(cell where (each.duongdi=true and each.connguoi=nil)) target:dichden speed:0.01;// cell=true co duong =nil khong can thi di
    	
		//cell c<-cell at location;
		//c.connguoi<-self;
		
		
    	if(location distance_to dichden<1){
    		dichden <- any_location_in (one_of (road));
        }
        
        
        // truong hop tat duong va hanh vi xu ly
        bool tatduong <- false;
        if(tatduong){
        	if (hanhvi = "quaydau"){
       			dichden <- nha;	
       			do goto  on:(cell where (each.duongdi=true and each.connguoi=nil)) target:dichden speed:0.01 recompute_path: true;	
        	}
        	if (hanhvi = "tieptuc"){
        		do goto  on:(cell where (each.leduong=true and each.connguoi=nil)) target:dichden speed:0.01;	
        	}	
        }
        
        
    	
    }
       
    aspect base {
  	  draw circle(1) color: color border: #black;
    }
}
grid cell width:50 height:50 neighbors:8{
	bool duongdi <-false;
	bool leduong <- false;
	
	people connguoi;
	rgb color <- #white;
	
	list<cell> neighbours_1  <- (self neighbors_at 1);
	
	
	
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
	
	
}

experiment khoitaotactu type: gui {
    parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
    parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;
    parameter "Shapefile for the bounds:" var: shape_file_bounds category: "GIS" ;
    parameter "Number of people agents" var: nb_people category: "People" ;
    
    output {
    display khotaitt type:opengl {
        species building aspect: base ;
        grid cell lines:#black;
        species road aspect: base ;
        species people aspect: base ;
    }
    }
}
