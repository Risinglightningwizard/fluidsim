shader_type canvas_item;
uniform sampler2D fluid;
uniform float angle : hint_range(0.0, 2.0, 0.01);
uniform float size : hint_range(10.0, 60.0, 0.01);
uniform float maxValue = 1.0;
void fragment() {
	
	//Isolate which cell the arrow is in and find center
	int cellNumx = int(UV.x*10.0);
	int cellNumy = int(UV.y*10.0);
	vec2 cellNum = vec2 (float(cellNumx)/10.0,float(cellNumy)/10.0);
	vec2 cellNumCenter = vec2 (cellNum.x + .05,cellNum.y + .05);
	
	vec4 color = texture(fluid,cellNumCenter);
	float rotation = atan(color.g,color.r) + 3.14159/4.0;
	float magnitude = (1.0/sqrt(color.r*color.r+color.g*color.g))/maxValue;
	float finalSize = magnitude * size*maxValue;
	
	//set rotation and area for rotation and shift
	vec2 pixelCellLoc = vec2(UV.x-cellNumCenter.x,UV.y-cellNumCenter.y);
	float xRotate = pixelCellLoc.x*cos(rotation) - pixelCellLoc.y*sin(rotation);
	float yRotate = pixelCellLoc.x*sin(rotation) + pixelCellLoc.y*cos(rotation);
	float rightEdge = .5/finalSize;
	float topEdge = .5/finalSize;
	vec4 arrowRotate = texture(TEXTURE, vec2((xRotate)*finalSize + 0.5, (yRotate)*finalSize + .5)*1.0);
	
	//grid
	if(int(UV.x * 200.0 + 20.0)%20 == 0 || int(UV.x * 200.0 + 21.0)%20 == 0){
		COLOR = vec4(.0, .0, .0, 1.0);
	}
	else if(int(UV.y * 200.0 + 20.0)%20 == 0 || int(UV.y * 200.0 + 21.0)%20 == 0){
		COLOR = vec4(.0, .0, .0, 1.0);
	}
	//arrow draw
	else if(arrowRotate.a != 0.0 && xRotate < rightEdge && xRotate > -1.0*rightEdge && yRotate < topEdge && yRotate > -1.0*topEdge){
		COLOR = arrowRotate;
	}
	else{
		COLOR = vec4(.0,.0,.0,.0);
	}
}
