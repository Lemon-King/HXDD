/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.util;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;

import net.mtrop.doom.graphics.Colormap;
import net.mtrop.doom.graphics.EndDoom;
import net.mtrop.doom.graphics.Flat;
import net.mtrop.doom.graphics.PNGPicture;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.graphics.Picture;
import net.mtrop.doom.object.GraphicObject;

/**
 * Graphics utility methods for image types.
 * @author Matthew Tropiano
 */
public final class GraphicUtils
{
	/** 
	 * Default Doom palette.
	 */
	public static final Palette DOOM = new Palette()
	{{
		setColorNoSort(0, 0, 0, 0);
		setColorNoSort(1, 31, 23, 11);
		setColorNoSort(2, 23, 15, 7);
		setColorNoSort(3, 75, 75, 75);
		setColorNoSort(4, 255, 255, 255);
		setColorNoSort(5, 27, 27, 27);
		setColorNoSort(6, 19, 19, 19);
		setColorNoSort(7, 11, 11, 11);
		setColorNoSort(8, 7, 7, 7);
		setColorNoSort(9, 47, 55, 31);
		setColorNoSort(10, 35, 43, 15);
		setColorNoSort(11, 23, 31, 7);
		setColorNoSort(12, 15, 23, 0);
		setColorNoSort(13, 79, 59, 43);
		setColorNoSort(14, 71, 51, 35);
		setColorNoSort(15, 63, 43, 27);
		setColorNoSort(16, 255, 183, 183);
		setColorNoSort(17, 247, 171, 171);
		setColorNoSort(18, 243, 163, 163);
		setColorNoSort(19, 235, 151, 151);
		setColorNoSort(20, 231, 143, 143);
		setColorNoSort(21, 223, 135, 135);
		setColorNoSort(22, 219, 123, 123);
		setColorNoSort(23, 211, 115, 115);
		setColorNoSort(24, 203, 107, 107);
		setColorNoSort(25, 199, 99, 99);
		setColorNoSort(26, 191, 91, 91);
		setColorNoSort(27, 187, 87, 87);
		setColorNoSort(28, 179, 79, 79);
		setColorNoSort(29, 175, 71, 71);
		setColorNoSort(30, 167, 63, 63);
		setColorNoSort(31, 163, 59, 59);
		setColorNoSort(32, 155, 51, 51);
		setColorNoSort(33, 151, 47, 47);
		setColorNoSort(34, 143, 43, 43);
		setColorNoSort(35, 139, 35, 35);
		setColorNoSort(36, 131, 31, 31);
		setColorNoSort(37, 127, 27, 27);
		setColorNoSort(38, 119, 23, 23);
		setColorNoSort(39, 115, 19, 19);
		setColorNoSort(40, 107, 15, 15);
		setColorNoSort(41, 103, 11, 11);
		setColorNoSort(42, 95, 7, 7);
		setColorNoSort(43, 91, 7, 7);
		setColorNoSort(44, 83, 7, 7);
		setColorNoSort(45, 79, 0, 0);
		setColorNoSort(46, 71, 0, 0);
		setColorNoSort(47, 67, 0, 0);
		setColorNoSort(48, 255, 235, 223);
		setColorNoSort(49, 255, 227, 211);
		setColorNoSort(50, 255, 219, 199);
		setColorNoSort(51, 255, 211, 187);
		setColorNoSort(52, 255, 207, 179);
		setColorNoSort(53, 255, 199, 167);
		setColorNoSort(54, 255, 191, 155);
		setColorNoSort(55, 255, 187, 147);
		setColorNoSort(56, 255, 179, 131);
		setColorNoSort(57, 247, 171, 123);
		setColorNoSort(58, 239, 163, 115);
		setColorNoSort(59, 231, 155, 107);
		setColorNoSort(60, 223, 147, 99);
		setColorNoSort(61, 215, 139, 91);
		setColorNoSort(62, 207, 131, 83);
		setColorNoSort(63, 203, 127, 79);
		setColorNoSort(64, 191, 123, 75);
		setColorNoSort(65, 179, 115, 71);
		setColorNoSort(66, 171, 111, 67);
		setColorNoSort(67, 163, 107, 63);
		setColorNoSort(68, 155, 99, 59);
		setColorNoSort(69, 143, 95, 55);
		setColorNoSort(70, 135, 87, 51);
		setColorNoSort(71, 127, 83, 47);
		setColorNoSort(72, 119, 79, 43);
		setColorNoSort(73, 107, 71, 39);
		setColorNoSort(74, 95, 67, 35);
		setColorNoSort(75, 83, 63, 31);
		setColorNoSort(76, 75, 55, 27);
		setColorNoSort(77, 63, 47, 23);
		setColorNoSort(78, 51, 43, 19);
		setColorNoSort(79, 43, 35, 15);
		setColorNoSort(80, 239, 239, 239);
		setColorNoSort(81, 231, 231, 231);
		setColorNoSort(82, 223, 223, 223);
		setColorNoSort(83, 219, 219, 219);
		setColorNoSort(84, 211, 211, 211);
		setColorNoSort(85, 203, 203, 203);
		setColorNoSort(86, 199, 199, 199);
		setColorNoSort(87, 191, 191, 191);
		setColorNoSort(88, 183, 183, 183);
		setColorNoSort(89, 179, 179, 179);
		setColorNoSort(90, 171, 171, 171);
		setColorNoSort(91, 167, 167, 167);
		setColorNoSort(92, 159, 159, 159);
		setColorNoSort(93, 151, 151, 151);
		setColorNoSort(94, 147, 147, 147);
		setColorNoSort(95, 139, 139, 139);
		setColorNoSort(96, 131, 131, 131);
		setColorNoSort(97, 127, 127, 127);
		setColorNoSort(98, 119, 119, 119);
		setColorNoSort(99, 111, 111, 111);
		setColorNoSort(100, 107, 107, 107);
		setColorNoSort(101, 99, 99, 99);
		setColorNoSort(102, 91, 91, 91);
		setColorNoSort(103, 87, 87, 87);
		setColorNoSort(104, 79, 79, 79);
		setColorNoSort(105, 71, 71, 71);
		setColorNoSort(106, 67, 67, 67);
		setColorNoSort(107, 59, 59, 59);
		setColorNoSort(108, 55, 55, 55);
		setColorNoSort(109, 47, 47, 47);
		setColorNoSort(110, 39, 39, 39);
		setColorNoSort(111, 35, 35, 35);
		setColorNoSort(112, 119, 255, 111);
		setColorNoSort(113, 111, 239, 103);
		setColorNoSort(114, 103, 223, 95);
		setColorNoSort(115, 95, 207, 87);
		setColorNoSort(116, 91, 191, 79);
		setColorNoSort(117, 83, 175, 71);
		setColorNoSort(118, 75, 159, 63);
		setColorNoSort(119, 67, 147, 55);
		setColorNoSort(120, 63, 131, 47);
		setColorNoSort(121, 55, 115, 43);
		setColorNoSort(122, 47, 99, 35);
		setColorNoSort(123, 39, 83, 27);
		setColorNoSort(124, 31, 67, 23);
		setColorNoSort(125, 23, 51, 15);
		setColorNoSort(126, 19, 35, 11);
		setColorNoSort(127, 11, 23, 7);
		setColorNoSort(128, 191, 167, 143);
		setColorNoSort(129, 183, 159, 135);
		setColorNoSort(130, 175, 151, 127);
		setColorNoSort(131, 167, 143, 119);
		setColorNoSort(132, 159, 135, 111);
		setColorNoSort(133, 155, 127, 107);
		setColorNoSort(134, 147, 123, 99);
		setColorNoSort(135, 139, 115, 91);
		setColorNoSort(136, 131, 107, 87);
		setColorNoSort(137, 123, 99, 79);
		setColorNoSort(138, 119, 95, 75);
		setColorNoSort(139, 111, 87, 67);
		setColorNoSort(140, 103, 83, 63);
		setColorNoSort(141, 95, 75, 55);
		setColorNoSort(142, 87, 67, 51);
		setColorNoSort(143, 83, 63, 47);
		setColorNoSort(144, 159, 131, 99);
		setColorNoSort(145, 143, 119, 83);
		setColorNoSort(146, 131, 107, 75);
		setColorNoSort(147, 119, 95, 63);
		setColorNoSort(148, 103, 83, 51);
		setColorNoSort(149, 91, 71, 43);
		setColorNoSort(150, 79, 59, 35);
		setColorNoSort(151, 67, 51, 27);
		setColorNoSort(152, 123, 127, 99);
		setColorNoSort(153, 111, 115, 87);
		setColorNoSort(154, 103, 107, 79);
		setColorNoSort(155, 91, 99, 71);
		setColorNoSort(156, 83, 87, 59);
		setColorNoSort(157, 71, 79, 51);
		setColorNoSort(158, 63, 71, 43);
		setColorNoSort(159, 55, 63, 39);
		setColorNoSort(160, 255, 255, 115);
		setColorNoSort(161, 235, 219, 87);
		setColorNoSort(162, 215, 187, 67);
		setColorNoSort(163, 195, 155, 47);
		setColorNoSort(164, 175, 123, 31);
		setColorNoSort(165, 155, 91, 19);
		setColorNoSort(166, 135, 67, 7);
		setColorNoSort(167, 115, 43, 0);
		setColorNoSort(168, 255, 255, 255);
		setColorNoSort(169, 255, 219, 219);
		setColorNoSort(170, 255, 187, 187);
		setColorNoSort(171, 255, 155, 155);
		setColorNoSort(172, 255, 123, 123);
		setColorNoSort(173, 255, 95, 95);
		setColorNoSort(174, 255, 63, 63);
		setColorNoSort(175, 255, 31, 31);
		setColorNoSort(176, 255, 0, 0);
		setColorNoSort(177, 239, 0, 0);
		setColorNoSort(178, 227, 0, 0);
		setColorNoSort(179, 215, 0, 0);
		setColorNoSort(180, 203, 0, 0);
		setColorNoSort(181, 191, 0, 0);
		setColorNoSort(182, 179, 0, 0);
		setColorNoSort(183, 167, 0, 0);
		setColorNoSort(184, 155, 0, 0);
		setColorNoSort(185, 139, 0, 0);
		setColorNoSort(186, 127, 0, 0);
		setColorNoSort(187, 115, 0, 0);
		setColorNoSort(188, 103, 0, 0);
		setColorNoSort(189, 91, 0, 0);
		setColorNoSort(190, 79, 0, 0);
		setColorNoSort(191, 67, 0, 0);
		setColorNoSort(192, 231, 231, 255);
		setColorNoSort(193, 199, 199, 255);
		setColorNoSort(194, 171, 171, 255);
		setColorNoSort(195, 143, 143, 255);
		setColorNoSort(196, 115, 115, 255);
		setColorNoSort(197, 83, 83, 255);
		setColorNoSort(198, 55, 55, 255);
		setColorNoSort(199, 27, 27, 255);
		setColorNoSort(200, 0, 0, 255);
		setColorNoSort(201, 0, 0, 227);
		setColorNoSort(202, 0, 0, 203);
		setColorNoSort(203, 0, 0, 179);
		setColorNoSort(204, 0, 0, 155);
		setColorNoSort(205, 0, 0, 131);
		setColorNoSort(206, 0, 0, 107);
		setColorNoSort(207, 0, 0, 83);
		setColorNoSort(208, 255, 255, 255);
		setColorNoSort(209, 255, 235, 219);
		setColorNoSort(210, 255, 215, 187);
		setColorNoSort(211, 255, 199, 155);
		setColorNoSort(212, 255, 179, 123);
		setColorNoSort(213, 255, 163, 91);
		setColorNoSort(214, 255, 143, 59);
		setColorNoSort(215, 255, 127, 27);
		setColorNoSort(216, 243, 115, 23);
		setColorNoSort(217, 235, 111, 15);
		setColorNoSort(218, 223, 103, 15);
		setColorNoSort(219, 215, 95, 11);
		setColorNoSort(220, 203, 87, 7);
		setColorNoSort(221, 195, 79, 0);
		setColorNoSort(222, 183, 71, 0);
		setColorNoSort(223, 175, 67, 0);
		setColorNoSort(224, 255, 255, 255);
		setColorNoSort(225, 255, 255, 215);
		setColorNoSort(226, 255, 255, 179);
		setColorNoSort(227, 255, 255, 143);
		setColorNoSort(228, 255, 255, 107);
		setColorNoSort(229, 255, 255, 71);
		setColorNoSort(230, 255, 255, 35);
		setColorNoSort(231, 255, 255, 0);
		setColorNoSort(232, 167, 63, 0);
		setColorNoSort(233, 159, 55, 0);
		setColorNoSort(234, 147, 47, 0);
		setColorNoSort(235, 135, 35, 0);
		setColorNoSort(236, 79, 59, 39);
		setColorNoSort(237, 67, 47, 27);
		setColorNoSort(238, 55, 35, 19);
		setColorNoSort(239, 47, 27, 11);
		setColorNoSort(240, 0, 0, 83);
		setColorNoSort(241, 0, 0, 71);
		setColorNoSort(242, 0, 0, 59);
		setColorNoSort(243, 0, 0, 47);
		setColorNoSort(244, 0, 0, 35);
		setColorNoSort(245, 0, 0, 23);
		setColorNoSort(246, 0, 0, 11);
		setColorNoSort(247, 0, 0, 0);
		setColorNoSort(248, 255, 159, 67);
		setColorNoSort(249, 255, 231, 75);
		setColorNoSort(250, 255, 123, 255);
		setColorNoSort(251, 255, 0, 255);
		setColorNoSort(252, 207, 0, 207);
		setColorNoSort(253, 159, 0, 155);
		setColorNoSort(254, 111, 0, 107);
		setColorNoSort(255, 167, 107, 107);
		sortIndices();
	}};
	
	/** 
	 * Default Heretic palette.
	 */
	public static final Palette HERETIC = new Palette()
	{{
		setColorNoSort(0, 2, 2, 2);
		setColorNoSort(1, 2, 2, 2);
		setColorNoSort(2, 16, 16, 16);
		setColorNoSort(3, 24, 24, 24);
		setColorNoSort(4, 31, 31, 31);
		setColorNoSort(5, 36, 36, 36);
		setColorNoSort(6, 44, 44, 44);
		setColorNoSort(7, 48, 48, 48);
		setColorNoSort(8, 55, 55, 55);
		setColorNoSort(9, 63, 63, 63);
		setColorNoSort(10, 70, 70, 70);
		setColorNoSort(11, 78, 78, 78);
		setColorNoSort(12, 86, 86, 86);
		setColorNoSort(13, 93, 93, 93);
		setColorNoSort(14, 101, 101, 101);
		setColorNoSort(15, 108, 108, 108);
		setColorNoSort(16, 116, 116, 116);
		setColorNoSort(17, 124, 124, 124);
		setColorNoSort(18, 131, 131, 131);
		setColorNoSort(19, 139, 139, 139);
		setColorNoSort(20, 146, 146, 146);
		setColorNoSort(21, 154, 154, 154);
		setColorNoSort(22, 162, 162, 162);
		setColorNoSort(23, 169, 169, 169);
		setColorNoSort(24, 177, 177, 177);
		setColorNoSort(25, 184, 184, 184);
		setColorNoSort(26, 192, 192, 192);
		setColorNoSort(27, 200, 200, 200);
		setColorNoSort(28, 207, 207, 207);
		setColorNoSort(29, 210, 210, 210);
		setColorNoSort(30, 215, 215, 215);
		setColorNoSort(31, 222, 222, 222);
		setColorNoSort(32, 228, 228, 228);
		setColorNoSort(33, 236, 236, 236);
		setColorNoSort(34, 245, 245, 245);
		setColorNoSort(35, 255, 255, 255);
		setColorNoSort(36, 50, 50, 50);
		setColorNoSort(37, 59, 60, 59);
		setColorNoSort(38, 69, 72, 68);
		setColorNoSort(39, 78, 80, 77);
		setColorNoSort(40, 88, 93, 86);
		setColorNoSort(41, 97, 100, 95);
		setColorNoSort(42, 109, 112, 104);
		setColorNoSort(43, 116, 123, 112);
		setColorNoSort(44, 125, 131, 121);
		setColorNoSort(45, 134, 141, 130);
		setColorNoSort(46, 144, 151, 139);
		setColorNoSort(47, 153, 161, 148);
		setColorNoSort(48, 163, 171, 157);
		setColorNoSort(49, 172, 181, 166);
		setColorNoSort(50, 181, 189, 176);
		setColorNoSort(51, 189, 196, 185);
		setColorNoSort(52, 20, 16, 36);
		setColorNoSort(53, 24, 24, 44);
		setColorNoSort(54, 36, 36, 60);
		setColorNoSort(55, 52, 52, 80);
		setColorNoSort(56, 68, 68, 96);
		setColorNoSort(57, 88, 88, 116);
		setColorNoSort(58, 108, 108, 136);
		setColorNoSort(59, 124, 124, 152);
		setColorNoSort(60, 148, 148, 172);
		setColorNoSort(61, 164, 164, 184);
		setColorNoSort(62, 180, 184, 200);
		setColorNoSort(63, 192, 196, 208);
		setColorNoSort(64, 208, 208, 216);
		setColorNoSort(65, 224, 224, 224);
		setColorNoSort(66, 27, 15, 8);
		setColorNoSort(67, 38, 20, 11);
		setColorNoSort(68, 49, 27, 14);
		setColorNoSort(69, 61, 31, 14);
		setColorNoSort(70, 65, 35, 18);
		setColorNoSort(71, 74, 37, 19);
		setColorNoSort(72, 83, 43, 19);
		setColorNoSort(73, 87, 47, 23);
		setColorNoSort(74, 95, 51, 27);
		setColorNoSort(75, 103, 59, 31);
		setColorNoSort(76, 115, 67, 35);
		setColorNoSort(77, 123, 75, 39);
		setColorNoSort(78, 131, 83, 47);
		setColorNoSort(79, 143, 91, 51);
		setColorNoSort(80, 151, 99, 59);
		setColorNoSort(81, 160, 108, 64);
		setColorNoSort(82, 175, 116, 74);
		setColorNoSort(83, 180, 126, 81);
		setColorNoSort(84, 192, 135, 91);
		setColorNoSort(85, 204, 143, 93);
		setColorNoSort(86, 213, 151, 103);
		setColorNoSort(87, 216, 159, 115);
		setColorNoSort(88, 220, 167, 126);
		setColorNoSort(89, 223, 175, 138);
		setColorNoSort(90, 227, 183, 149);
		setColorNoSort(91, 230, 190, 161);
		setColorNoSort(92, 233, 198, 172);
		setColorNoSort(93, 237, 206, 184);
		setColorNoSort(94, 240, 214, 195);
		setColorNoSort(95, 62, 40, 11);
		setColorNoSort(96, 75, 50, 16);
		setColorNoSort(97, 84, 59, 23);
		setColorNoSort(98, 95, 67, 30);
		setColorNoSort(99, 103, 75, 38);
		setColorNoSort(100, 110, 83, 47);
		setColorNoSort(101, 123, 95, 55);
		setColorNoSort(102, 137, 107, 62);
		setColorNoSort(103, 150, 118, 75);
		setColorNoSort(104, 163, 129, 84);
		setColorNoSort(105, 171, 137, 92);
		setColorNoSort(106, 180, 146, 101);
		setColorNoSort(107, 188, 154, 109);
		setColorNoSort(108, 196, 162, 117);
		setColorNoSort(109, 204, 170, 125);
		setColorNoSort(110, 208, 176, 133);
		setColorNoSort(111, 37, 20, 4);
		setColorNoSort(112, 47, 24, 4);
		setColorNoSort(113, 57, 28, 6);
		setColorNoSort(114, 68, 33, 4);
		setColorNoSort(115, 76, 36, 3);
		setColorNoSort(116, 84, 40, 0);
		setColorNoSort(117, 97, 47, 2);
		setColorNoSort(118, 114, 54, 0);
		setColorNoSort(119, 125, 63, 6);
		setColorNoSort(120, 141, 75, 9);
		setColorNoSort(121, 155, 83, 17);
		setColorNoSort(122, 162, 95, 21);
		setColorNoSort(123, 169, 103, 26);
		setColorNoSort(124, 180, 113, 32);
		setColorNoSort(125, 188, 124, 20);
		setColorNoSort(126, 204, 136, 24);
		setColorNoSort(127, 220, 148, 28);
		setColorNoSort(128, 236, 160, 23);
		setColorNoSort(129, 244, 172, 47);
		setColorNoSort(130, 252, 187, 57);
		setColorNoSort(131, 252, 194, 70);
		setColorNoSort(132, 251, 201, 83);
		setColorNoSort(133, 251, 208, 97);
		setColorNoSort(134, 251, 214, 110);
		setColorNoSort(135, 251, 221, 123);
		setColorNoSort(136, 250, 228, 136);
		setColorNoSort(137, 157, 51, 4);
		setColorNoSort(138, 170, 65, 2);
		setColorNoSort(139, 185, 86, 4);
		setColorNoSort(140, 213, 118, 4);
		setColorNoSort(141, 236, 164, 3);
		setColorNoSort(142, 248, 190, 3);
		setColorNoSort(143, 255, 216, 43);
		setColorNoSort(144, 255, 255, 0);
		setColorNoSort(145, 67, 0, 0);
		setColorNoSort(146, 79, 0, 0);
		setColorNoSort(147, 91, 0, 0);
		setColorNoSort(148, 103, 0, 0);
		setColorNoSort(149, 115, 0, 0);
		setColorNoSort(150, 127, 0, 0);
		setColorNoSort(151, 139, 0, 0);
		setColorNoSort(152, 155, 0, 0);
		setColorNoSort(153, 167, 0, 0);
		setColorNoSort(154, 179, 0, 0);
		setColorNoSort(155, 191, 0, 0);
		setColorNoSort(156, 203, 0, 0);
		setColorNoSort(157, 215, 0, 0);
		setColorNoSort(158, 227, 0, 0);
		setColorNoSort(159, 239, 0, 0);
		setColorNoSort(160, 255, 0, 0);
		setColorNoSort(161, 255, 52, 52);
		setColorNoSort(162, 255, 74, 74);
		setColorNoSort(163, 255, 95, 95);
		setColorNoSort(164, 255, 123, 123);
		setColorNoSort(165, 255, 155, 155);
		setColorNoSort(166, 255, 179, 179);
		setColorNoSort(167, 255, 201, 201);
		setColorNoSort(168, 255, 215, 215);
		setColorNoSort(169, 60, 12, 88);
		setColorNoSort(170, 80, 8, 108);
		setColorNoSort(171, 104, 8, 128);
		setColorNoSort(172, 128, 0, 144);
		setColorNoSort(173, 152, 0, 176);
		setColorNoSort(174, 184, 0, 224);
		setColorNoSort(175, 216, 44, 252);
		setColorNoSort(176, 224, 120, 240);
		setColorNoSort(177, 37, 6, 129);
		setColorNoSort(178, 60, 33, 147);
		setColorNoSort(179, 82, 61, 165);
		setColorNoSort(180, 105, 88, 183);
		setColorNoSort(181, 128, 116, 201);
		setColorNoSort(182, 151, 143, 219);
		setColorNoSort(183, 173, 171, 237);
		setColorNoSort(184, 196, 198, 255);
		setColorNoSort(185, 2, 4, 41);
		setColorNoSort(186, 2, 5, 49);
		setColorNoSort(187, 6, 8, 57);
		setColorNoSort(188, 2, 5, 65);
		setColorNoSort(189, 2, 5, 79);
		setColorNoSort(190, 0, 4, 88);
		setColorNoSort(191, 0, 4, 96);
		setColorNoSort(192, 0, 4, 104);
		setColorNoSort(193, 2, 5, 121);
		setColorNoSort(194, 2, 5, 137);
		setColorNoSort(195, 6, 9, 159);
		setColorNoSort(196, 12, 16, 184);
		setColorNoSort(197, 32, 40, 200);
		setColorNoSort(198, 56, 60, 220);
		setColorNoSort(199, 80, 80, 253);
		setColorNoSort(200, 80, 108, 252);
		setColorNoSort(201, 80, 136, 252);
		setColorNoSort(202, 80, 164, 252);
		setColorNoSort(203, 80, 196, 252);
		setColorNoSort(204, 72, 220, 252);
		setColorNoSort(205, 80, 236, 252);
		setColorNoSort(206, 84, 252, 252);
		setColorNoSort(207, 152, 252, 252);
		setColorNoSort(208, 188, 252, 244);
		setColorNoSort(209, 11, 23, 7);
		setColorNoSort(210, 19, 35, 11);
		setColorNoSort(211, 23, 51, 15);
		setColorNoSort(212, 31, 67, 23);
		setColorNoSort(213, 39, 83, 27);
		setColorNoSort(214, 47, 99, 35);
		setColorNoSort(215, 55, 115, 43);
		setColorNoSort(216, 63, 131, 47);
		setColorNoSort(217, 67, 147, 55);
		setColorNoSort(218, 75, 159, 63);
		setColorNoSort(219, 83, 175, 71);
		setColorNoSort(220, 91, 191, 79);
		setColorNoSort(221, 95, 207, 87);
		setColorNoSort(222, 103, 223, 95);
		setColorNoSort(223, 111, 239, 103);
		setColorNoSort(224, 119, 255, 111);
		setColorNoSort(225, 23, 31, 23);
		setColorNoSort(226, 27, 35, 27);
		setColorNoSort(227, 31, 43, 31);
		setColorNoSort(228, 35, 51, 35);
		setColorNoSort(229, 43, 55, 43);
		setColorNoSort(230, 47, 63, 47);
		setColorNoSort(231, 51, 71, 51);
		setColorNoSort(232, 59, 75, 55);
		setColorNoSort(233, 63, 83, 59);
		setColorNoSort(234, 67, 91, 67);
		setColorNoSort(235, 75, 95, 71);
		setColorNoSort(236, 79, 103, 75);
		setColorNoSort(237, 87, 111, 79);
		setColorNoSort(238, 91, 115, 83);
		setColorNoSort(239, 95, 123, 87);
		setColorNoSort(240, 103, 131, 95);
		setColorNoSort(241, 255, 223, 0);
		setColorNoSort(242, 255, 191, 0);
		setColorNoSort(243, 255, 159, 0);
		setColorNoSort(244, 255, 127, 0);
		setColorNoSort(245, 255, 95, 0);
		setColorNoSort(246, 255, 63, 0);
		setColorNoSort(247, 244, 14, 3);
		setColorNoSort(248, 55, 0, 0);
		setColorNoSort(249, 47, 0, 0);
		setColorNoSort(250, 39, 0, 0);
		setColorNoSort(251, 23, 0, 0);
		setColorNoSort(252, 15, 15, 15);
		setColorNoSort(253, 11, 11, 11);
		setColorNoSort(254, 7, 7, 7);
		setColorNoSort(255, 255, 255, 255);
		sortIndices();
	}};
	
	/** 
	 * Default Hexen palette.
	 */
	public static final Palette HEXEN = new Palette()
	{{
		setColorNoSort(0, 2, 2, 2);
		setColorNoSort(1, 4, 4, 4);
		setColorNoSort(2, 15, 15, 15);
		setColorNoSort(3, 19, 19, 19);
		setColorNoSort(4, 27, 27, 27);
		setColorNoSort(5, 28, 28, 28);
		setColorNoSort(6, 33, 33, 33);
		setColorNoSort(7, 39, 39, 39);
		setColorNoSort(8, 45, 45, 45);
		setColorNoSort(9, 51, 51, 51);
		setColorNoSort(10, 57, 57, 57);
		setColorNoSort(11, 63, 63, 63);
		setColorNoSort(12, 69, 69, 69);
		setColorNoSort(13, 75, 75, 75);
		setColorNoSort(14, 81, 81, 81);
		setColorNoSort(15, 86, 86, 86);
		setColorNoSort(16, 92, 92, 92);
		setColorNoSort(17, 98, 98, 98);
		setColorNoSort(18, 104, 104, 104);
		setColorNoSort(19, 112, 112, 112);
		setColorNoSort(20, 121, 121, 121);
		setColorNoSort(21, 130, 130, 130);
		setColorNoSort(22, 139, 139, 139);
		setColorNoSort(23, 147, 147, 147);
		setColorNoSort(24, 157, 157, 157);
		setColorNoSort(25, 166, 166, 166);
		setColorNoSort(26, 176, 176, 176);
		setColorNoSort(27, 185, 185, 185);
		setColorNoSort(28, 194, 194, 194);
		setColorNoSort(29, 203, 203, 203);
		setColorNoSort(30, 212, 212, 212);
		setColorNoSort(31, 221, 221, 221);
		setColorNoSort(32, 230, 230, 230);
		setColorNoSort(33, 29, 32, 29);
		setColorNoSort(34, 38, 40, 37);
		setColorNoSort(35, 50, 50, 50);
		setColorNoSort(36, 59, 60, 59);
		setColorNoSort(37, 69, 72, 68);
		setColorNoSort(38, 78, 80, 77);
		setColorNoSort(39, 88, 93, 86);
		setColorNoSort(40, 97, 100, 95);
		setColorNoSort(41, 109, 112, 104);
		setColorNoSort(42, 116, 123, 112);
		setColorNoSort(43, 125, 131, 121);
		setColorNoSort(44, 134, 141, 130);
		setColorNoSort(45, 144, 151, 139);
		setColorNoSort(46, 153, 161, 148);
		setColorNoSort(47, 163, 171, 157);
		setColorNoSort(48, 172, 181, 166);
		setColorNoSort(49, 181, 189, 176);
		setColorNoSort(50, 189, 196, 185);
		setColorNoSort(51, 22, 29, 22);
		setColorNoSort(52, 27, 36, 27);
		setColorNoSort(53, 31, 43, 31);
		setColorNoSort(54, 35, 51, 35);
		setColorNoSort(55, 43, 55, 43);
		setColorNoSort(56, 47, 63, 47);
		setColorNoSort(57, 51, 71, 51);
		setColorNoSort(58, 59, 75, 55);
		setColorNoSort(59, 63, 83, 59);
		setColorNoSort(60, 67, 91, 67);
		setColorNoSort(61, 75, 95, 71);
		setColorNoSort(62, 79, 103, 75);
		setColorNoSort(63, 87, 111, 79);
		setColorNoSort(64, 91, 115, 83);
		setColorNoSort(65, 95, 123, 87);
		setColorNoSort(66, 103, 131, 95);
		setColorNoSort(67, 20, 16, 36);
		setColorNoSort(68, 30, 26, 46);
		setColorNoSort(69, 40, 36, 57);
		setColorNoSort(70, 50, 46, 67);
		setColorNoSort(71, 59, 57, 78);
		setColorNoSort(72, 69, 67, 88);
		setColorNoSort(73, 79, 77, 99);
		setColorNoSort(74, 89, 87, 109);
		setColorNoSort(75, 99, 97, 120);
		setColorNoSort(76, 109, 107, 130);
		setColorNoSort(77, 118, 118, 141);
		setColorNoSort(78, 128, 128, 151);
		setColorNoSort(79, 138, 138, 162);
		setColorNoSort(80, 148, 148, 172);
		setColorNoSort(81, 62, 40, 11);
		setColorNoSort(82, 75, 50, 16);
		setColorNoSort(83, 84, 59, 23);
		setColorNoSort(84, 95, 67, 30);
		setColorNoSort(85, 103, 75, 38);
		setColorNoSort(86, 110, 83, 47);
		setColorNoSort(87, 123, 95, 55);
		setColorNoSort(88, 137, 107, 62);
		setColorNoSort(89, 150, 118, 75);
		setColorNoSort(90, 163, 129, 84);
		setColorNoSort(91, 171, 137, 92);
		setColorNoSort(92, 180, 146, 101);
		setColorNoSort(93, 188, 154, 109);
		setColorNoSort(94, 196, 162, 117);
		setColorNoSort(95, 204, 170, 125);
		setColorNoSort(96, 208, 176, 133);
		setColorNoSort(97, 27, 15, 8);
		setColorNoSort(98, 38, 20, 11);
		setColorNoSort(99, 49, 27, 14);
		setColorNoSort(100, 61, 31, 14);
		setColorNoSort(101, 65, 35, 18);
		setColorNoSort(102, 74, 37, 19);
		setColorNoSort(103, 83, 43, 19);
		setColorNoSort(104, 87, 47, 23);
		setColorNoSort(105, 95, 51, 27);
		setColorNoSort(106, 103, 59, 31);
		setColorNoSort(107, 115, 67, 35);
		setColorNoSort(108, 123, 75, 39);
		setColorNoSort(109, 131, 83, 47);
		setColorNoSort(110, 143, 91, 51);
		setColorNoSort(111, 151, 99, 59);
		setColorNoSort(112, 160, 108, 64);
		setColorNoSort(113, 175, 116, 74);
		setColorNoSort(114, 180, 126, 81);
		setColorNoSort(115, 192, 135, 91);
		setColorNoSort(116, 204, 143, 93);
		setColorNoSort(117, 213, 151, 103);
		setColorNoSort(118, 216, 159, 115);
		setColorNoSort(119, 220, 167, 126);
		setColorNoSort(120, 223, 175, 138);
		setColorNoSort(121, 227, 183, 149);
		setColorNoSort(122, 37, 20, 4);
		setColorNoSort(123, 47, 24, 4);
		setColorNoSort(124, 57, 28, 6);
		setColorNoSort(125, 68, 33, 4);
		setColorNoSort(126, 76, 36, 3);
		setColorNoSort(127, 84, 40, 0);
		setColorNoSort(128, 97, 47, 2);
		setColorNoSort(129, 114, 54, 0);
		setColorNoSort(130, 125, 63, 6);
		setColorNoSort(131, 141, 75, 9);
		setColorNoSort(132, 155, 83, 17);
		setColorNoSort(133, 162, 95, 21);
		setColorNoSort(134, 169, 103, 26);
		setColorNoSort(135, 180, 113, 32);
		setColorNoSort(136, 188, 124, 20);
		setColorNoSort(137, 204, 136, 24);
		setColorNoSort(138, 220, 148, 28);
		setColorNoSort(139, 236, 160, 23);
		setColorNoSort(140, 244, 172, 47);
		setColorNoSort(141, 252, 187, 57);
		setColorNoSort(142, 252, 194, 70);
		setColorNoSort(143, 251, 201, 83);
		setColorNoSort(144, 251, 208, 97);
		setColorNoSort(145, 251, 221, 123);
		setColorNoSort(146, 2, 4, 41);
		setColorNoSort(147, 2, 5, 49);
		setColorNoSort(148, 6, 8, 57);
		setColorNoSort(149, 2, 5, 65);
		setColorNoSort(150, 2, 5, 79);
		setColorNoSort(151, 0, 4, 88);
		setColorNoSort(152, 0, 4, 96);
		setColorNoSort(153, 0, 4, 104);
		setColorNoSort(154, 4, 6, 121);
		setColorNoSort(155, 2, 5, 137);
		setColorNoSort(156, 20, 23, 152);
		setColorNoSort(157, 38, 41, 167);
		setColorNoSort(158, 56, 59, 181);
		setColorNoSort(159, 74, 77, 196);
		setColorNoSort(160, 91, 94, 211);
		setColorNoSort(161, 109, 112, 226);
		setColorNoSort(162, 127, 130, 240);
		setColorNoSort(163, 145, 148, 255);
		setColorNoSort(164, 31, 4, 4);
		setColorNoSort(165, 39, 0, 0);
		setColorNoSort(166, 47, 0, 0);
		setColorNoSort(167, 55, 0, 0);
		setColorNoSort(168, 67, 0, 0);
		setColorNoSort(169, 79, 0, 0);
		setColorNoSort(170, 91, 0, 0);
		setColorNoSort(171, 103, 0, 0);
		setColorNoSort(172, 115, 0, 0);
		setColorNoSort(173, 127, 0, 0);
		setColorNoSort(174, 139, 0, 0);
		setColorNoSort(175, 155, 0, 0);
		setColorNoSort(176, 167, 0, 0);
		setColorNoSort(177, 185, 0, 0);
		setColorNoSort(178, 202, 0, 0);
		setColorNoSort(179, 220, 0, 0);
		setColorNoSort(180, 237, 0, 0);
		setColorNoSort(181, 255, 0, 0);
		setColorNoSort(182, 255, 46, 46);
		setColorNoSort(183, 255, 91, 91);
		setColorNoSort(184, 255, 137, 137);
		setColorNoSort(185, 255, 171, 171);
		setColorNoSort(186, 20, 16, 4);
		setColorNoSort(187, 13, 24, 9);
		setColorNoSort(188, 17, 33, 12);
		setColorNoSort(189, 21, 41, 14);
		setColorNoSort(190, 24, 50, 17);
		setColorNoSort(191, 28, 57, 20);
		setColorNoSort(192, 32, 65, 24);
		setColorNoSort(193, 35, 73, 28);
		setColorNoSort(194, 39, 80, 31);
		setColorNoSort(195, 44, 86, 37);
		setColorNoSort(196, 46, 95, 38);
		setColorNoSort(197, 51, 104, 43);
		setColorNoSort(198, 60, 122, 51);
		setColorNoSort(199, 68, 139, 58);
		setColorNoSort(200, 77, 157, 66);
		setColorNoSort(201, 85, 174, 73);
		setColorNoSort(202, 94, 192, 81);
		setColorNoSort(203, 157, 51, 4);
		setColorNoSort(204, 170, 65, 2);
		setColorNoSort(205, 185, 86, 4);
		setColorNoSort(206, 213, 119, 6);
		setColorNoSort(207, 234, 147, 5);
		setColorNoSort(208, 255, 178, 6);
		setColorNoSort(209, 255, 195, 26);
		setColorNoSort(210, 255, 216, 45);
		setColorNoSort(211, 4, 133, 4);
		setColorNoSort(212, 8, 175, 8);
		setColorNoSort(213, 2, 215, 2);
		setColorNoSort(214, 3, 234, 3);
		setColorNoSort(215, 42, 252, 42);
		setColorNoSort(216, 121, 255, 121);
		setColorNoSort(217, 3, 3, 184);
		setColorNoSort(218, 15, 41, 220);
		setColorNoSort(219, 28, 80, 226);
		setColorNoSort(220, 41, 119, 233);
		setColorNoSort(221, 54, 158, 239);
		setColorNoSort(222, 67, 197, 246);
		setColorNoSort(223, 80, 236, 252);
		setColorNoSort(224, 244, 14, 3);
		setColorNoSort(225, 255, 63, 0);
		setColorNoSort(226, 255, 95, 0);
		setColorNoSort(227, 255, 127, 0);
		setColorNoSort(228, 255, 159, 0);
		setColorNoSort(229, 255, 195, 26);
		setColorNoSort(230, 255, 223, 0);
		setColorNoSort(231, 43, 13, 64);
		setColorNoSort(232, 61, 14, 89);
		setColorNoSort(233, 90, 15, 122);
		setColorNoSort(234, 120, 16, 156);
		setColorNoSort(235, 149, 16, 189);
		setColorNoSort(236, 178, 17, 222);
		setColorNoSort(237, 197, 74, 232);
		setColorNoSort(238, 215, 129, 243);
		setColorNoSort(239, 234, 169, 253);
		setColorNoSort(240, 61, 16, 16);
		setColorNoSort(241, 90, 36, 33);
		setColorNoSort(242, 118, 56, 49);
		setColorNoSort(243, 147, 77, 66);
		setColorNoSort(244, 176, 97, 83);
		setColorNoSort(245, 204, 117, 99);
		setColorNoSort(246, 71, 53, 2);
		setColorNoSort(247, 81, 63, 6);
		setColorNoSort(248, 96, 72, 0);
		setColorNoSort(249, 108, 80, 0);
		setColorNoSort(250, 120, 88, 0);
		setColorNoSort(251, 128, 96, 0);
		setColorNoSort(252, 149, 112, 1);
		setColorNoSort(253, 181, 136, 3);
		setColorNoSort(254, 212, 160, 4);
		setColorNoSort(255, 255, 255, 255);
		sortIndices();
	}};
	
	/** 
	 * Default Strife palette.
	 */
	public static final Palette STRIFE = new Palette()
	{{
		setColorNoSort(0, 0, 0, 0);
		setColorNoSort(1, 231, 227, 227);
		setColorNoSort(2, 223, 219, 219);
		setColorNoSort(3, 215, 211, 211);
		setColorNoSort(4, 207, 203, 203);
		setColorNoSort(5, 199, 195, 195);
		setColorNoSort(6, 191, 191, 191);
		setColorNoSort(7, 183, 183, 183);
		setColorNoSort(8, 179, 175, 175);
		setColorNoSort(9, 171, 167, 167);
		setColorNoSort(10, 163, 159, 159);
		setColorNoSort(11, 155, 151, 151);
		setColorNoSort(12, 147, 147, 147);
		setColorNoSort(13, 139, 139, 139);
		setColorNoSort(14, 131, 131, 131);
		setColorNoSort(15, 123, 123, 123);
		setColorNoSort(16, 119, 115, 115);
		setColorNoSort(17, 111, 111, 111);
		setColorNoSort(18, 103, 103, 103);
		setColorNoSort(19, 95, 95, 95);
		setColorNoSort(20, 87, 87, 87);
		setColorNoSort(21, 79, 79, 79);
		setColorNoSort(22, 71, 71, 71);
		setColorNoSort(23, 67, 63, 63);
		setColorNoSort(24, 59, 59, 59);
		setColorNoSort(25, 51, 51, 51);
		setColorNoSort(26, 43, 43, 43);
		setColorNoSort(27, 35, 35, 35);
		setColorNoSort(28, 27, 27, 27);
		setColorNoSort(29, 19, 19, 19);
		setColorNoSort(30, 11, 11, 11);
		setColorNoSort(31, 7, 7, 7);
		setColorNoSort(32, 187, 191, 183);
		setColorNoSort(33, 179, 183, 171);
		setColorNoSort(34, 167, 179, 159);
		setColorNoSort(35, 163, 171, 147);
		setColorNoSort(36, 155, 167, 139);
		setColorNoSort(37, 147, 159, 127);
		setColorNoSort(38, 139, 155, 119);
		setColorNoSort(39, 131, 147, 107);
		setColorNoSort(40, 127, 143, 103);
		setColorNoSort(41, 119, 135, 91);
		setColorNoSort(42, 115, 131, 83);
		setColorNoSort(43, 107, 123, 75);
		setColorNoSort(44, 103, 119, 67);
		setColorNoSort(45, 99, 111, 63);
		setColorNoSort(46, 91, 107, 55);
		setColorNoSort(47, 87, 99, 47);
		setColorNoSort(48, 83, 95, 43);
		setColorNoSort(49, 75, 87, 35);
		setColorNoSort(50, 71, 83, 31);
		setColorNoSort(51, 67, 75, 27);
		setColorNoSort(52, 63, 71, 23);
		setColorNoSort(53, 59, 63, 19);
		setColorNoSort(54, 51, 59, 15);
		setColorNoSort(55, 47, 51, 11);
		setColorNoSort(56, 43, 47, 7);
		setColorNoSort(57, 39, 43, 7);
		setColorNoSort(58, 31, 35, 7);
		setColorNoSort(59, 27, 31, 0);
		setColorNoSort(60, 23, 23, 0);
		setColorNoSort(61, 15, 19, 0);
		setColorNoSort(62, 11, 11, 0);
		setColorNoSort(63, 7, 7, 0);
		setColorNoSort(64, 219, 43, 43);
		setColorNoSort(65, 203, 35, 35);
		setColorNoSort(66, 191, 31, 31);
		setColorNoSort(67, 175, 27, 27);
		setColorNoSort(68, 163, 23, 23);
		setColorNoSort(69, 147, 19, 19);
		setColorNoSort(70, 135, 15, 15);
		setColorNoSort(71, 119, 11, 11);
		setColorNoSort(72, 107, 7, 7);
		setColorNoSort(73, 91, 7, 7);
		setColorNoSort(74, 79, 0, 0);
		setColorNoSort(75, 63, 0, 0);
		setColorNoSort(76, 51, 0, 0);
		setColorNoSort(77, 39, 0, 0);
		setColorNoSort(78, 23, 0, 0);
		setColorNoSort(79, 11, 0, 0);
		setColorNoSort(80, 235, 231, 0);
		setColorNoSort(81, 231, 211, 0);
		setColorNoSort(82, 215, 179, 0);
		setColorNoSort(83, 199, 151, 0);
		setColorNoSort(84, 183, 127, 0);
		setColorNoSort(85, 167, 103, 0);
		setColorNoSort(86, 151, 83, 0);
		setColorNoSort(87, 135, 63, 0);
		setColorNoSort(88, 119, 47, 0);
		setColorNoSort(89, 103, 35, 0);
		setColorNoSort(90, 87, 23, 0);
		setColorNoSort(91, 71, 11, 0);
		setColorNoSort(92, 55, 7, 0);
		setColorNoSort(93, 39, 0, 0);
		setColorNoSort(94, 23, 0, 0);
		setColorNoSort(95, 11, 0, 0);
		setColorNoSort(96, 183, 231, 127);
		setColorNoSort(97, 163, 215, 111);
		setColorNoSort(98, 143, 199, 95);
		setColorNoSort(99, 127, 183, 79);
		setColorNoSort(100, 107, 171, 67);
		setColorNoSort(101, 91, 155, 55);
		setColorNoSort(102, 75, 139, 43);
		setColorNoSort(103, 63, 123, 35);
		setColorNoSort(104, 47, 111, 27);
		setColorNoSort(105, 35, 95, 19);
		setColorNoSort(106, 23, 79, 11);
		setColorNoSort(107, 15, 67, 7);
		setColorNoSort(108, 7, 51, 7);
		setColorNoSort(109, 0, 35, 0);
		setColorNoSort(110, 0, 19, 0);
		setColorNoSort(111, 0, 7, 0);
		setColorNoSort(112, 199, 207, 255);
		setColorNoSort(113, 183, 187, 239);
		setColorNoSort(114, 163, 171, 219);
		setColorNoSort(115, 151, 155, 203);
		setColorNoSort(116, 135, 139, 187);
		setColorNoSort(117, 123, 127, 171);
		setColorNoSort(118, 107, 111, 155);
		setColorNoSort(119, 95, 99, 139);
		setColorNoSort(120, 83, 83, 123);
		setColorNoSort(121, 67, 71, 107);
		setColorNoSort(122, 55, 59, 91);
		setColorNoSort(123, 47, 47, 75);
		setColorNoSort(124, 35, 35, 59);
		setColorNoSort(125, 23, 23, 43);
		setColorNoSort(126, 15, 15, 27);
		setColorNoSort(127, 0, 0, 11);
		setColorNoSort(128, 199, 191, 147);
		setColorNoSort(129, 179, 171, 131);
		setColorNoSort(130, 167, 155, 119);
		setColorNoSort(131, 155, 139, 111);
		setColorNoSort(132, 143, 127, 99);
		setColorNoSort(133, 131, 111, 91);
		setColorNoSort(134, 119, 99, 79);
		setColorNoSort(135, 107, 87, 71);
		setColorNoSort(136, 91, 71, 59);
		setColorNoSort(137, 79, 59, 51);
		setColorNoSort(138, 67, 47, 43);
		setColorNoSort(139, 55, 39, 35);
		setColorNoSort(140, 43, 27, 27);
		setColorNoSort(141, 31, 19, 19);
		setColorNoSort(142, 19, 11, 11);
		setColorNoSort(143, 7, 7, 0);
		setColorNoSort(144, 143, 195, 211);
		setColorNoSort(145, 123, 179, 195);
		setColorNoSort(146, 107, 167, 183);
		setColorNoSort(147, 91, 155, 167);
		setColorNoSort(148, 75, 139, 155);
		setColorNoSort(149, 59, 127, 139);
		setColorNoSort(150, 47, 115, 127);
		setColorNoSort(151, 35, 103, 115);
		setColorNoSort(152, 27, 91, 99);
		setColorNoSort(153, 19, 79, 87);
		setColorNoSort(154, 11, 67, 71);
		setColorNoSort(155, 7, 55, 59);
		setColorNoSort(156, 0, 43, 43);
		setColorNoSort(157, 0, 31, 31);
		setColorNoSort(158, 0, 19, 19);
		setColorNoSort(159, 0, 7, 7);
		setColorNoSort(160, 211, 191, 175);
		setColorNoSort(161, 203, 179, 163);
		setColorNoSort(162, 195, 171, 151);
		setColorNoSort(163, 191, 159, 143);
		setColorNoSort(164, 183, 151, 131);
		setColorNoSort(165, 175, 143, 123);
		setColorNoSort(166, 171, 135, 115);
		setColorNoSort(167, 163, 123, 103);
		setColorNoSort(168, 155, 115, 95);
		setColorNoSort(169, 151, 107, 87);
		setColorNoSort(170, 143, 99, 79);
		setColorNoSort(171, 139, 91, 71);
		setColorNoSort(172, 131, 83, 67);
		setColorNoSort(173, 123, 75, 59);
		setColorNoSort(174, 119, 67, 51);
		setColorNoSort(175, 111, 59, 47);
		setColorNoSort(176, 103, 55, 39);
		setColorNoSort(177, 99, 47, 35);
		setColorNoSort(178, 91, 43, 31);
		setColorNoSort(179, 83, 35, 27);
		setColorNoSort(180, 79, 31, 23);
		setColorNoSort(181, 71, 27, 19);
		setColorNoSort(182, 63, 19, 15);
		setColorNoSort(183, 59, 15, 11);
		setColorNoSort(184, 51, 11, 7);
		setColorNoSort(185, 43, 7, 7);
		setColorNoSort(186, 39, 7, 0);
		setColorNoSort(187, 31, 0, 0);
		setColorNoSort(188, 27, 0, 0);
		setColorNoSort(189, 19, 0, 0);
		setColorNoSort(190, 11, 0, 0);
		setColorNoSort(191, 7, 0, 0);
		setColorNoSort(192, 211, 199, 187);
		setColorNoSort(193, 203, 191, 179);
		setColorNoSort(194, 195, 183, 171);
		setColorNoSort(195, 191, 175, 163);
		setColorNoSort(196, 183, 167, 155);
		setColorNoSort(197, 175, 159, 147);
		setColorNoSort(198, 171, 151, 139);
		setColorNoSort(199, 163, 143, 135);
		setColorNoSort(200, 155, 139, 127);
		setColorNoSort(201, 151, 131, 119);
		setColorNoSort(202, 143, 123, 111);
		setColorNoSort(203, 135, 115, 107);
		setColorNoSort(204, 131, 107, 99);
		setColorNoSort(205, 123, 103, 95);
		setColorNoSort(206, 115, 95, 87);
		setColorNoSort(207, 111, 87, 83);
		setColorNoSort(208, 103, 83, 75);
		setColorNoSort(209, 95, 75, 71);
		setColorNoSort(210, 91, 67, 63);
		setColorNoSort(211, 83, 63, 59);
		setColorNoSort(212, 79, 55, 51);
		setColorNoSort(213, 71, 51, 47);
		setColorNoSort(214, 63, 43, 43);
		setColorNoSort(215, 59, 39, 39);
		setColorNoSort(216, 51, 35, 31);
		setColorNoSort(217, 43, 27, 27);
		setColorNoSort(218, 39, 23, 23);
		setColorNoSort(219, 31, 19, 19);
		setColorNoSort(220, 23, 15, 15);
		setColorNoSort(221, 19, 11, 11);
		setColorNoSort(222, 11, 7, 7);
		setColorNoSort(223, 7, 7, 0);
		setColorNoSort(224, 239, 239, 0);
		setColorNoSort(225, 231, 215, 0);
		setColorNoSort(226, 227, 191, 0);
		setColorNoSort(227, 219, 171, 0);
		setColorNoSort(228, 215, 151, 0);
		setColorNoSort(229, 211, 131, 0);
		setColorNoSort(230, 203, 111, 0);
		setColorNoSort(231, 199, 91, 0);
		setColorNoSort(232, 191, 75, 0);
		setColorNoSort(233, 187, 59, 0);
		setColorNoSort(234, 183, 43, 0);
		setColorNoSort(235, 255, 0, 0);
		setColorNoSort(236, 223, 0, 0);
		setColorNoSort(237, 191, 0, 0);
		setColorNoSort(238, 159, 0, 0);
		setColorNoSort(239, 127, 0, 0);
		setColorNoSort(240, 0, 0, 0);
		setColorNoSort(241, 139, 199, 103);
		setColorNoSort(242, 107, 171, 75);
		setColorNoSort(243, 79, 143, 55);
		setColorNoSort(244, 55, 115, 35);
		setColorNoSort(245, 35, 87, 19);
		setColorNoSort(246, 19, 63, 11);
		setColorNoSort(247, 215, 223, 255);
		setColorNoSort(248, 187, 203, 247);
		setColorNoSort(249, 143, 167, 219);
		setColorNoSort(250, 99, 131, 195);
		setColorNoSort(251, 63, 91, 167);
		setColorNoSort(252, 203, 203, 203);
		setColorNoSort(253, 215, 215, 215);
		setColorNoSort(254, 223, 223, 223);
		setColorNoSort(255, 235, 235, 235);
		sortIndices();
	}};

	/** ANSI color table. */
	public static final Color[] ANSI_COLORS = {
		new Color(0,0,0),		//black
		new Color(0,0,171),		//blue
		new Color(0,171,0),		//green
		new Color(0,153,153),	//cyan
		new Color(171,0,0),		//red
		new Color(153,0,153), 	//magenta
		new Color(153,102,0),	//brown
		new Color(171,171,171),	//light gray
		new Color(84,84,84),	//dark gray
		new Color(102,102,255),	//light blue
		new Color(102,255,102),	//light green
		new Color(102,255,255),	//light cyan
		new Color(255,102,102),	//light red
		new Color(255,102,255),	//light magenta
		new Color(255,255,102),	//yellow
		new Color(255,255,255)	//white
	};

	private GraphicUtils() {}
	
	/**
	 * Creates a {@link Flat} from a {@link BufferedImage}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are given index 0. 
	 * @param image the image to convert.
	 * @param palette the palette to use for color approximation.
	 * @return the resultant Flat.
	 */
	public static Flat createFlat(BufferedImage image, Palette palette)
	{
		return createFlat(image, palette, null);
	}

	/**
	 * Creates a {@link Flat} from a {@link BufferedImage}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are given index 0. 
	 * @param image the image to convert.
	 * @param palette the palette to use for color approximation.
	 * @param colormap the colormap to use for palette translation. Can be <code>null</code> for no translation.
	 * @return the resultant Flat.
	 */
	public static Flat createFlat(BufferedImage image, Palette palette, Colormap colormap)
	{
		Flat out = new Flat(image.getWidth(), image.getHeight());
		for (int y = 0; y < out.getHeight(); y++)
			for (int x = 0; x < out.getWidth(); x++)
			{
				int argb = image.getRGB(x, y);
				if ((argb & 0xff000000) >>> 24 != 0x0ff)
					argb = 0;
				int index = palette.getNearestColorIndex((argb & 0x00ff0000) >> 16, (argb & 0x0000ff00) >> 8, (argb & 0x000000ff));
				index = colormap != null ? colormap.getPaletteIndex(index) : index;
				out.setPixel(x, y, index);
			}
		
		return out;
	}
	
	/**
	 * Creates a {@link Picture} from a {@link BufferedImage}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are considered transparent. 
	 * @param image the image to convert.
	 * @param palette the palette to use for color approximation.
	 * @return the resultant Picture.
	 */
	public static Picture createPicture(BufferedImage image, Palette palette)
	{
		return createPicture(image, palette, null);
	}

	/**
	 * Creates a {@link Picture} from a {@link BufferedImage}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are considered transparent. 
	 * @param image the image to convert.
	 * @param palette the palette to use for color approximation.
	 * @param colormap the colormap to use for palette translation. Can be <code>null</code> for no translation.
	 * @return the resultant Picture.
	 */
	public static Picture createPicture(BufferedImage image, Palette palette, Colormap colormap)
	{
		Picture out = new Picture(image.getWidth(), image.getHeight());
		for (int y = 0; y < out.getHeight(); y++)
			for (int x = 0; x < out.getWidth(); x++)
			{
				int argb = image.getRGB(x, y);
				if ((argb & 0xff000000) >>> 24 != 0x0ff)
					out.setPixel(x, y, Picture.PIXEL_TRANSLUCENT);
				else
				{
					int index = palette.getNearestColorIndex((argb & 0x00ff0000) >> 16, (argb & 0x0000ff00) >> 8, (argb & 0x000000ff));
					index = colormap != null ? colormap.getPaletteIndex(index) : index;
					out.setPixel(x, y, index);
				}
			}
		
		return out;
	}
	
	/**
	 * Creates a {@link Flat} from a {@link PNGPicture}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are given index 0. 
	 * @param pngPicture the PNGPicture to convert.
	 * @param palette the palette to use for color approximation.
	 * @return the resultant Flat.
	 * @since 2.13.0
	 */
	public static Flat createFlat(PNGPicture pngPicture, Palette palette)
	{
		return createFlat(pngPicture, palette, null);
	}

	/**
	 * Creates a {@link Flat} from a {@link PNGPicture}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are given index 0. 
	 * @param pngPicture the PNGPicture to convert.
	 * @param palette the palette to use for color approximation.
	 * @param colormap the colormap to use for palette translation. Can be <code>null</code> for no translation.
	 * @return the resultant Flat.
	 * @since 2.13.0
	 */
	public static Flat createFlat(PNGPicture pngPicture, Palette palette, Colormap colormap)
	{
		return createFlat(pngPicture.getImage(), palette, colormap);
	}
	
	/**
	 * Creates a {@link Picture} from a {@link BufferedImage}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are considered transparent. 
	 * Offset info from the PNG is preserved. 
	 * @param pngPicture the PNGPicture to convert.
	 * @param palette the palette to use for color approximation.
	 * @return the resultant Picture.
	 * @since 2.13.0
	 */
	public static Picture createPicture(PNGPicture pngPicture, Palette palette)
	{
		return createPicture(pngPicture, palette, null);
	}

	/**
	 * Creates a {@link Picture} from a {@link BufferedImage}.
	 * Colors are approximated using the provided {@link Palette}, and translated using the provided {@link Colormap}.
	 * Pixels that are not fully opaque are considered transparent. 
	 * Offset info from the PNG is preserved. 
	 * @param pngPicture the PNGPicture to convert.
	 * @param palette the palette to use for color approximation.
	 * @param colormap the colormap to use for palette translation. Can be <code>null</code> for no translation.
	 * @return the resultant Picture.
	 * @since 2.13.0
	 */
	public static Picture createPicture(PNGPicture pngPicture, Palette palette, Colormap colormap)
	{
		Picture out = createPicture(pngPicture.getImage(), palette, colormap);
		out.setOffsetX(pngPicture.getOffsetX());
		out.setOffsetY(pngPicture.getOffsetY());
		return out;
	}
	
	/**
	 * Creates a {@link BufferedImage} from a {@link Flat}.
	 * @param flat the Flat to convert.
	 * @param palette the palette to use as a color source.
	 * @return a full color image of the indexed-color Flat. 
	 */
	public static BufferedImage createImage(Flat flat, Palette palette)
	{
		return createImage(flat, palette, null);
	}

	/**
	 * Creates a {@link BufferedImage} from a {@link Flat}.
	 * @param flat the Flat to convert.
	 * @param palette the palette to use as a color source.
	 * @param colormap the colormap for palette translation, if any. Can be null for no translation.
	 * @return a full color image of the indexed-color Flat. 
	 */
	public static BufferedImage createImage(Flat flat, Palette palette, Colormap colormap)
	{
		BufferedImage out = new BufferedImage(flat.getWidth(), flat.getHeight(), BufferedImage.TYPE_INT_ARGB);
		for (int y = 0; y < out.getHeight(); y++)
			for (int x = 0; x < out.getWidth(); x++)
			{
				int index = colormap != null ? colormap.getPaletteIndex(flat.getPixel(x, y)) : flat.getPixel(x, y);
				int argb = palette.getColorARGB(index);
				out.setRGB(x, y, argb);
			}
		
		return out;
	}
	
	/**
	 * Creates a {@link BufferedImage} from a {@link Picture}.
	 * @param picture the Picture to convert.
	 * @param palette the palette to use as a color source.
	 * @return a full color image of the indexed-color Flat. 
	 */
	public static BufferedImage createImage(Picture picture, Palette palette)
	{
		return createImage(picture, palette, null);
	}

	/**
	 * Creates a {@link BufferedImage} from a {@link Flat}.
	 * @param picture the Picture to convert.
	 * @param palette the palette to use as a color source.
	 * @param colormap the colormap for palette translation, if any. Can be null for no translation.
	 * @return a full color image of the indexed-color Flat. 
	 */
	public static BufferedImage createImage(Picture picture, Palette palette, Colormap colormap)
	{
		BufferedImage out = new BufferedImage(picture.getWidth(), picture.getHeight(), BufferedImage.TYPE_INT_ARGB);
		for (int y = 0; y < out.getHeight(); y++)
			for (int x = 0; x < out.getWidth(); x++)
			{
				int index = picture.getPixel(x, y);
				if (index < 0)
					out.setRGB(x, y, 0);
				else
				{
					index = colormap != null ? colormap.getPaletteIndex(picture.getPixel(x, y)) : picture.getPixel(x, y);
					int argb = palette.getColorARGB(index);
					out.setRGB(x, y, argb);
				}
			}
		
		return out;
	}

	/**
	 * Creates a {@link PNGPicture} from a {@link Picture}.
	 * @param picture the Picture to convert.
	 * @param palette the palette to use as a color source.
	 * @return a full color image of the indexed-color Flat. 
	 */
	public static PNGPicture createPNGImage(Picture picture, Palette palette)
	{
		return createPNGImage(picture, palette, null);	
	}

	/**
	 * Creates a {@link PNGPicture} from a {@link Picture}.
	 * @param picture the Picture to convert.
	 * @param palette the palette to use as a color source.
	 * @param colormap the colormap for palette translation, if any. Can be null for no translation.
	 * @return a full color image of the indexed-color Flat. 
	 */
	public static PNGPicture createPNGImage(Picture picture, Palette palette, Colormap colormap)
	{
		return new PNGPicture(createImage(picture, palette, colormap));
	}

	/**
	 * Returns the EndDoom data rendered to a BufferedImage.
	 * @param endoom the EndDoom lump to render.
	 * @param blinking if true, this will render the "blinking" characters.
	 * @return a BufferedImage that represents the graphic image in RGB color (including transparency).
	 * @throws NullPointerException if endoom is null.
	 */
	public static BufferedImage createImageForEndDoom(EndDoom endoom, boolean blinking)
	{
		BufferedImage out = new BufferedImage(640, 300, BufferedImage.TYPE_INT_ARGB);
		Font font = new Font("Lucida Console", Font.PLAIN, 13);
		char[] ch = new char[1];
		Graphics2D g = (Graphics2D)out.getGraphics();
		g.setFont(font);
		g.setColor(ANSI_COLORS[0]);
		g.fillRect(0, 0, 640, 300);
		
		for (int r = 0; r < 25; r++)
			for (int c = 0; c < 80; c++)
			{
				g.setColor(ANSI_COLORS[endoom.getBackgroundColor(r, c)]);
				g.fillRect(c*8, r*12, 8, 12);
			}
		
		for (int r = 24; r >= 0; r--)
			for (int c = 79; c >= 0; c--)
			{
				if (blinking || (!blinking && endoom.getBlinking(r, c)))
				{
					g.setColor(ANSI_COLORS[endoom.getForegroundColor(r, c)]);
					ch[0] = endoom.getCharAt(r, c);
					g.drawChars(ch, 0, 1, c*8, r*12+10);
				}
			}
		return out;
	}

	/**
	 * Sets the indices of a {@link Colormap} by attempting to match colors in a palette from other colors in a different palette.
	 * <p>This is a convenience for:
	 * <pre>
	 * for (int i = 0; i &lt; Colormap.NUM_INDICES; i++)
	 *     colormap.setPaletteIndex(i, target.getNearestColorIndex(sampled.getColorARGB(i)))
	 * </pre>
	 * @param colormap the colormap to set.  
	 * @param target the palette to match against.
	 * @param sampled the palette to sample from for matching.
	 * @since 2.2.0
	 */
	public static void setColormap(Colormap colormap, Palette target, Palette sampled)
	{
		for (int i = 0; i < Colormap.NUM_INDICES; i++)
			colormap.setPaletteIndex(i, target.getNearestColorIndex(sampled.getColorARGB(i)));
	}
		
	/**
	 * Creates a series of colormaps using a two-dimensional graphic, assumed indexed.
	 * The provided indexed graphic must have a width of at least {@link Colormap#NUM_INDICES}.
	 * The amount of colormaps returned is equal to the graphic height. Translucent pixels are changed to index 0.
	 * @param graphic the source graphic to use.
	 * @return an array of new colormaps.
	 * @throws NullPointerException if graphic is null.
	 * @throws ArrayIndexOutOfBoundsException if the provided graphic's width is less than {@link Colormap#NUM_INDICES}.
	 * @since 2.2.0
	 */
	public static Colormap[] createColormapsFromGraphic(GraphicObject graphic)
	{
		Colormap[] out = new Colormap[graphic.getHeight()];
		for (int i = 0; i < out.length; i++)
			for (int x = 0; x < Colormap.NUM_INDICES; x++)
				out[i].setPaletteIndex(x, Math.max(graphic.getPixel(x, i), 0));
		return out;
	}
		
}
