def python_VioletPulse(timg, tdrawable, frameBlend=3, bb=3, opacityDrop=0.7):
	width = tdrawable.width
	height = tdrawable.height
	img = gimp.Image(width, height, RGB)
	img.disable_undo()	
	gimp.progress_init()	
	nLayers = len(timg.layers)	
	for i in range(nLayers-frameBlend):
		opacityStart = 100
		newLayer = gimp.Layer(img, "frame-{0}".format(i), width, height, RGB_IMAGE, 100, NORMAL_MODE)
		img.add_layer(newLayer, 0)
		pdb.gimp_edit_fill(newLayer, 0)
		for j in range(frameBlend):
			mergingLayer = gimp.Layer(img, "frame-temp-{0}".format(i+j), width, height, RGB_IMAGE, opacityStart, SCREEN_MODE)
			img.add_layer(mergingLayer)
			pdb.gimp_selection_all(timg);
			pdb.gimp_edit_copy(timg.layers[(i+j)])
			floater = pdb.gimp_edit_paste(img.active_drawable, 1)
			# time.sleep(1)
			pdb.gimp_floating_sel_anchor(floater)
			if j > 0:
				pdb.plug_in_gauss_rle(img, mergingLayer, bb * j, 1, 1)
			opacityStart = opacityStart * opacityDrop			
		finalLayer = img.merge_visible_layers(0)
		finalLayer.visible = False
		# time.sleep(1)
		gimp.progress_update(0.5 * i / nLayers)
	img2 = gimp.Image(width, height, RGB)
	img2.disable_undo()	
	nLayers2 = len(img.layers)	
	for i in range(nLayers2):
		mergeOnto = gimp.Layer(img2, "framewithtext-{0}".format(i), width, height, RGB_IMAGE, 100, NORMAL_MODE)
		img2.add_layer(mergeOnto, 0)
		pdb.gimp_selection_all(img);
		pdb.gimp_edit_copy(img.layers[i])
		floater = pdb.gimp_edit_paste(img2.active_drawable, 1)
		pdb.gimp_floating_sel_anchor(floater)
		pdb.gimp_selection_all(img);
		pdb.gimp_edit_copy(timg.layers[nLayers-1])
		floater = pdb.gimp_edit_paste(img2.active_drawable, 1)
		pdb.gimp_floating_sel_anchor(floater)
		pdb.file_png_save_defaults(img2, mergeOnto, "C:/Users/telpi/Desktop/VioletPulse/{0}.png".format(mergeOnto.name), "C:/Users/telpi/Desktop/VioletPulse/{0}.png".format(mergeOnto.name))
		# time.sleep(1)
		gimp.progress_update(0.5 + 0.5 * i / nLayers2)		
	gimp.delete(img)
	gimp.Display(img2)
	






img = gimp.image_list()[0]
dbl = img.active_drawable
python_VioletPulse(img, dbl)


ffmpeg -r 33.5 -f image2 -s 652x256 -i "C:\Users\telpi\Desktop\VioletPulse\framewithtext-%d.png" -vcodec libxvid -g 15 -b:v 1500000 -pix_fmt yuv420p "C:\Users\telpi\Desktop\VioletPulse\VP-test.mp4"