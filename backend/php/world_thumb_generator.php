<?php 

$patch_img_path = '../img/patch_256x256_72dpi.png' ; 
list($patch_width, $patch_height) = getimagesize($patch_img_path);
$qubit_img_path = '../img/qubit_48x48_72dpi.png' ; 
list($qubit_width, $qubit_height) = getimagesize($qubit_img_path);
$qubit_alpha = 50;
$num_of_qubits = 16;
$qubit_padding = 5;
$x_start = 28;
$y_start = 28;

$bg_img = imagecreatefrompng($patch_img_path);
$fg_img = imagecreatefrompng($qubit_img_path);

imagealphablending($bg_img, false);
imagesavealpha($bg_img, true);
imagealphablending($fg_img, false);
imagesavealpha($fg_img, true);

for($i=0;$i<$num_of_qubits;$i++) {
	if ($i<3) {
		$x_1 = $x_start ;
		$y_1 = $y_start ;
		$x_2 = $qubit_width; //($qubit_width*$i)+$qubit_padding
		$y_2 = $qubit_height; // ($qubit_height*$i)+$qubit_padding
	} 
	if ($i>3 && $i<7)  {
		$x_1 = $x_start-($qubit_width+$qubit_padding)*4;
		$y_1 = $y_start+$qubit_height+$qubit_padding;
		//$x_2 = $qubit_width; //($qubit_width*$i)+$qubit_padding
		//$y_2 = $qubit_height; // ($qubit_height*$i)+$qubit_padding
	}
	if ($i>7 && $i<11)  {
		$x_1 = $x_start-($qubit_width+$qubit_padding)*8;
		$y_1 = $y_start+($qubit_height+$qubit_padding)*2;
		//$x_2 = $qubit_width; //($qubit_width*$i)+$qubit_padding
		//$y_2 = $qubit_height; // ($qubit_height*$i)+$qubit_padding
	}
	if ($i>11 && $i<15)  {
		$x_1 = $x_start-($qubit_width+$qubit_padding)*12;
		$y_1 = $y_start+($qubit_height+$qubit_padding)*3;
		//$x_2 = $qubit_width; //($qubit_width*$i)+$qubit_padding
		//$y_2 = $qubit_height; // ($qubit_height*$i)+$qubit_padding
	}
	imagecopymerge($bg_img, $fg_img, ($x_1)+($qubit_width+$qubit_padding)*$i, $y_1, $x_2, $y_2, $qubit_width, $qubit_height, $qubit_alpha);
}

header('Content-Type: image/png');
imagepng($bg_img);

imagedestroy($bg_img);
imagedestroy($fg_img);

?>