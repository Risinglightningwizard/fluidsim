extends Sprite2D
var output_texture_width := 10
var output_texture_height := 10
@export var curve = Curve
func _ready():
	# Create a local rendering device.
	var rd := RenderingServer.create_local_rendering_device()
	# Load GLSL shader
	var shader_file := load("res://imageedit.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	
	# create texture format
	var fmt := RDTextureFormat.new()
	fmt.width = output_texture_width
	fmt.height = output_texture_height
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | \
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	#create image
	var view := RDTextureView.new()
	var output_image := Image.create(output_texture_width, output_texture_height, false, Image.FORMAT_RGBAF)
	var output_tex = rd.texture_create(fmt, view, [output_image.get_data()])
	
	#create uniform and uniform set
	var output_tex_uniform := RDUniform.new()
	output_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_tex_uniform.binding = 0
	output_tex_uniform.add_id(output_tex)

	var uniform_set:= rd.uniform_set_create([output_tex_uniform], shader, 0) 
	
	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 1, 1, 1)
	rd.compute_list_end()
	
	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()
	
	#retrieve data
	var output_bytes := rd.texture_get_data(output_tex,0)
	var output := output_bytes.to_float32_array()
	print("Output: ", output)
	
	var finalImage := Image.create_from_data(output_texture_width, output_texture_height,\
		 false, Image.FORMAT_RGBAF, output_bytes)
	
	var finaltex := ImageTexture.create_from_image(finalImage)
	print(finaltex.get_format())
	#self.texture = finaltex
	material.set("shader_parameter/fluid", finaltex)
