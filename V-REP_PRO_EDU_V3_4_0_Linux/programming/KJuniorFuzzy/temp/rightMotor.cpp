// Project FLIE-Fuzzy Logic Inference Engine - Jo�o Alberto Fabro - out/1996

// File flie.cc

#include <stdlib.h> // Random!
#include <stdio.h> // Random!
#define DOS
#include "rightMotor.h"

/*Deve-se definir um sistema de controle que ir� conter as regras.*/
fuzzy_control fuzzycontrolD;

/*No programa principal � necess�rio instanciar as vari�veis para conter
todos os conjuntos fuzzy e tamb�m defini-los.*/

trapezoid_category cat1[21];



/*Deve-se definir as vari�veis lingu�sticas que ir�o conter os conjuntos fuzzy*/

linguisticvariable sens_front, sens_right, sens_left, lingRightMotor;



/*Deve-se definir as regras de infer�ncia que ir�o reger o comportamento do
sistema de controle.� necess�rio instanci�-los.*/

//TODO
rule infruleD[99];

rightMotor::rightMotor(){
	mainD();
}

rightMotor::~rightMotor(){

}

void rightMotor::mainD()
{
        int i;



/*deve-se definir vari�veis que ir�o conter as entradas e sa�das(defuzificadas)
do sistema submetidas ao controle.*/

float SumError, ControlOutput;


/* Define-se os conjuntos fuzzy para a vari�vel lingu�stica Error*/

	/*
	 MP = Muito Perto
	 P  = Perto
	 M  = M�dio
	 L  = Longe
	 ML = Muito Longe
	*/

	cat1[0].setname("ML");
	cat1[0].setrange(0, 400);
	cat1[0].setval(0, 0, 395, 400);

	cat1[1].setname("L");
	cat1[1].setrange(395, 605);
	cat1[1].setval(395, 400, 600, 605);

	cat1[2].setname("M");
	cat1[2].setrange(600, 805);
	cat1[2].setval(600, 605, 800, 805);

	cat1[3].setname("P");
	cat1[3].setrange(800, 900);
	cat1[3].setval(800, 805, 895, 900);

	cat1[4].setname("MP");
	cat1[4].setrange(895, 1000);
	cat1[4].setval(895, 900, 1000, 1000);

	// cat1[0].setname("ML");
	// cat1[0].setrange(990, 1000);
	// cat1[0].setval(980, 990, 1000, 1000);

	// cat1[1].setname("L");
	// cat1[1].setrange(960, 990);
	// cat1[1].setval(960, 970, 980, 990);

	// cat1[2].setname("M");
	// cat1[2].setrange(890, 970);
	// cat1[2].setval(890, 900, 960, 970);

	// cat1[3].setname("P");
	// cat1[3].setrange(800, 900);
	// cat1[3].setval(800, 810, 890, 900);

	// cat1[4].setname("MP");
	// cat1[4].setrange(0, 810);
	// cat1[4].setval(0, 0, 800, 810);


	/*Define-se a Vari�vel lingu�stica Error*/

	sens_right.setname("Sensores da direita");

	sens_right.includecategory(&cat1[0]);

	sens_right.includecategory(&cat1[1]);

	sens_right.includecategory(&cat1[2]);

	sens_right.includecategory(&cat1[3]);

	sens_right.includecategory(&cat1[4]);


	cat1[5].setname("ML");
	cat1[5].setrange(0, 400);
	cat1[5].setval(0, 0, 395, 400);

	cat1[6].setname("L");
	cat1[6].setrange(395, 605);
	cat1[6].setval(395, 400, 600, 605);

	cat1[7].setname("M");
	cat1[7].setrange(600, 805);
	cat1[7].setval(600, 605, 800, 805);

	cat1[8].setname("P");
	cat1[8].setrange(800, 900);
	cat1[8].setval(800, 805, 895, 900);

	cat1[9].setname("MP");
	cat1[9].setrange(895, 1000);
	cat1[9].setval(895, 900, 1000, 1000);

	// cat1[5].setname("ML");
	// cat1[5].setrange(990, 1000);
	// cat1[5].setval(980, 990, 1000, 1000);

	// cat1[6].setname("L");
	// cat1[6].setrange(960, 990);
	// cat1[6].setval(960, 970, 980, 990);

	// cat1[7].setname("M");
	// cat1[7].setrange(890, 970);
	// cat1[7].setval(890, 900, 960, 970);

	// cat1[8].setname("P");
	// cat1[8].setrange(800, 900);
	// cat1[8].setval(800, 810, 890, 900);

	// cat1[9].setname("MP");
	// cat1[9].setrange(0, 810);
	// cat1[9].setval(0, 0, 800, 810);


	/*Define-se a Vari�vel lingu�stica Error*/

	sens_left.setname("Sensores da esquerda");

	sens_left.includecategory(&cat1[5]);

	sens_left.includecategory(&cat1[6]);

	sens_left.includecategory(&cat1[7]);

	sens_left.includecategory(&cat1[8]);

	sens_left.includecategory(&cat1[9]);



	/*Define-se os conjuntos fuzzy para a vari�vel lingu�stica Control*/

	cat1[10].setname("ML");
	cat1[10].setrange(0, 400);
	cat1[10].setval(0, 0, 395, 400);

	cat1[11].setname("L");
	cat1[11].setrange(395, 605);
	cat1[11].setval(395, 400, 600, 605);

	cat1[12].setname("M");
	cat1[12].setrange(600, 805);
	cat1[12].setval(600, 605, 800, 805);

	cat1[13].setname("P");
	cat1[13].setrange(800, 900);
	cat1[13].setval(800, 805, 895, 900);

	cat1[14].setname("MP");
	cat1[14].setrange(895, 1000);
	cat1[14].setval(895, 900, 1000, 1000);

	// cat1[10].setname("ML");
	// cat1[10].setrange(990, 1000);
	// cat1[10].setval(980, 990, 1000, 1000);

	// cat1[11].setname("L");
	// cat1[11].setrange(960, 990);
	// cat1[11].setval(960, 970, 980, 990);

	// cat1[12].setname("M");
	// cat1[12].setrange(890, 970);
	// cat1[12].setval(890, 900, 960, 970);

	// cat1[13].setname("P");
	// cat1[13].setrange(800, 900);
	// cat1[13].setval(800, 810, 890, 900);

	// cat1[14].setname("MP");
	// cat1[14].setrange(0, 810);
	// cat1[14].setval(0, 0, 800, 810);


	/*Defini-se a Vari�vel lingu�stica Error*/

	sens_front.setname("Sensores da frente");

	sens_front.includecategory(&cat1[10]);

	sens_front.includecategory(&cat1[11]);

	sens_front.includecategory(&cat1[12]);

	sens_front.includecategory(&cat1[13]);

	sens_front.includecategory(&cat1[14]);

	/*
	 RT = Rapido pra Tr�s
	 MT = M�dio pra Tr�s
	 DT = Devagar pra Tr�s
	 DF = Devagar pra Frente
	 MF = M�dio pra Frente
	 RF = R�pido pra Frente
	 */

	/*Define-se os conjuntos fuzzy para a vari�vel lingu�stica Control*/

	cat1[15].setname("RT");
	cat1[15].setrange(-10, -7);
	cat1[15].setval(-10, -10, -8, -7);

	cat1[16].setname("MT");
	cat1[16].setrange(-8,-2);
	cat1[16].setval(-8, -7, -3, -2);

	cat1[17].setname("DT");
	cat1[17].setrange(-3, 1);
	cat1[17].setval(-3, -2, -1, 1);

	cat1[18].setname("DF");
	cat1[18].setrange(-1, 3);
	cat1[18].setval(-1, 1, 2, 3);

	cat1[19].setname("MF");
	cat1[19].setrange(2, 8);
	cat1[19].setval(2, 3, 7, 8);

	cat1[20].setname("RF");
	cat1[20].setrange(7, 10);
	cat1[20].setval(7, 8, 10, 10);


	/*Defini-se a vari�vel lingu�stica Control*/

	lingRightMotor.setname("Controle");

	lingRightMotor.includecategory(&cat1[15]);

	lingRightMotor.includecategory(&cat1[16]);

	lingRightMotor.includecategory(&cat1[17]);

	lingRightMotor.includecategory(&cat1[18]);

	lingRightMotor.includecategory(&cat1[19]);

	lingRightMotor.includecategory(&cat1[20]);

/*Defini-se o m�todo defuzzifica��o*/

fuzzycontrolD.set_defuzz(CENTEROFAREA);


/* Defini-se o fuzzy_control pelas entradas fuzzy( Error, DeltaError)
e sa�das (Control) )*/

fuzzycontrolD.definevars(sens_left, sens_front, sens_right, lingRightMotor);



/*Deve-se incluir cada regra fuzzy no fuzzy_control*/



	//Regras para Muito Perto com o sensor da esquerda
	//girar K-Junior para a direita
	//

	fuzzycontrolD.insert_rule("MP","P","P","RT");
	fuzzycontrolD.insert_rule("MP","P","M","RT");
	fuzzycontrolD.insert_rule("MP","P","L","RT");
	fuzzycontrolD.insert_rule("MP","P","ML","RT");

	fuzzycontrolD.insert_rule("MP","M","P","RT");
	fuzzycontrolD.insert_rule("MP","M","M","RT");
	fuzzycontrolD.insert_rule("MP","M","L","RT");
	fuzzycontrolD.insert_rule("MP","M","ML","RT");

	fuzzycontrolD.insert_rule("MP","L","P","RT");
	fuzzycontrolD.insert_rule("MP","L","M","RT");
	fuzzycontrolD.insert_rule("MP","L","L","RT");
	fuzzycontrolD.insert_rule("MP","L","ML","RT");

	fuzzycontrolD.insert_rule("P","P","P","RT");
	fuzzycontrolD.insert_rule("P","P","M","RT");
	fuzzycontrolD.insert_rule("P","P","L","RT");
	fuzzycontrolD.insert_rule("P","P","ML","RT");

	fuzzycontrolD.insert_rule("P","M","P","RT");
	fuzzycontrolD.insert_rule("P","M","M","RT");
	fuzzycontrolD.insert_rule("P","M","L","RT");
	fuzzycontrolD.insert_rule("P","M","ML","RT");

	fuzzycontrolD.insert_rule("P","L","P","RT");
	fuzzycontrolD.insert_rule("P","L","M","RT");
	fuzzycontrolD.insert_rule("P","L","L","RT");
	fuzzycontrolD.insert_rule("P","L","ML","RT");


	//Regras para M�dio com sensor esquerda
	//girar K-Junior para a direita
	//
	fuzzycontrolD.insert_rule("M","P","P","RT");
	fuzzycontrolD.insert_rule("M","P","M","RT");
	fuzzycontrolD.insert_rule("M","P","L","RT");
	fuzzycontrolD.insert_rule("M","P","ML","RT");

	fuzzycontrolD.insert_rule("M","M","P","RT");
	fuzzycontrolD.insert_rule("M","M","M","RT");
	fuzzycontrolD.insert_rule("M","M","L","RT");
	fuzzycontrolD.insert_rule("M","M","ML","RT");

	fuzzycontrolD.insert_rule("M","L","P","RT");
	fuzzycontrolD.insert_rule("M","L","M","RT");
	fuzzycontrolD.insert_rule("M","L","L","RT");
	fuzzycontrolD.insert_rule("M","L","ML","RT");



	//Regras para Muito Perto com o sensor da direita
	//girar K-Junior para a esquerda
	//

	fuzzycontrolD.insert_rule("P","P","MP","RF");
	fuzzycontrolD.insert_rule("M","P","MP","RF");
	fuzzycontrolD.insert_rule("L","P","MP","RF");
	fuzzycontrolD.insert_rule("ML","P","MP","RF");

	fuzzycontrolD.insert_rule("P","M","MP","RF");
	fuzzycontrolD.insert_rule("M","M","MP","RF");
	fuzzycontrolD.insert_rule("L","M","MP","RF");
	fuzzycontrolD.insert_rule("ML","M","MP","RF");

	fuzzycontrolD.insert_rule("P","L","MP","RF");
	fuzzycontrolD.insert_rule("M","L","MP","RF");
	fuzzycontrolD.insert_rule("L","L","MP","RF");
	fuzzycontrolD.insert_rule("ML","L","MP","RF");


	//Regras para M�dio com o sensor da direita
	//girar K-Junior para a esquerda
	//

	fuzzycontrolD.insert_rule("P","P","M","RF");
	fuzzycontrolD.insert_rule("M","P","M","RF");
	fuzzycontrolD.insert_rule("L","P","M","RF");
	fuzzycontrolD.insert_rule("ML","P","M","RF");

	fuzzycontrolD.insert_rule("P","M","M","RF");
	fuzzycontrolD.insert_rule("M","M","M","RF");
	fuzzycontrolD.insert_rule("L","M","M","RF");
	fuzzycontrolD.insert_rule("ML","M","M","RF");

	fuzzycontrolD.insert_rule("P","L","M","RF");
	fuzzycontrolD.insert_rule("M","L","M","RF");
	fuzzycontrolD.insert_rule("L","L","M","RF");

	fuzzycontrolD.insert_rule("P","P","P","RF");
	fuzzycontrolD.insert_rule("M","P","P","RF");
	fuzzycontrolD.insert_rule("L","P","P","RF");
	fuzzycontrolD.insert_rule("ML","P","P","RF");

	fuzzycontrolD.insert_rule("P","M","P","RF");
	fuzzycontrolD.insert_rule("M","M","P","RF");
	fuzzycontrolD.insert_rule("L","M","P","RF");
	fuzzycontrolD.insert_rule("ML","M","P","RF");

	fuzzycontrolD.insert_rule("P","L","P","RF");
	fuzzycontrolD.insert_rule("M","L","P","RF");
	fuzzycontrolD.insert_rule("L","L","P","RF");
	fuzzycontrolD.insert_rule("ML","L","P","RF");

	//Regras de controle � erros

	fuzzycontrolD.insert_rule("P","L","L","RT");
	fuzzycontrolD.insert_rule("L","M","M","RT");
	fuzzycontrolD.insert_rule("L","M","M","RT");
	fuzzycontrolD.insert_rule("L","ML","ML","RT");
	fuzzycontrolD.insert_rule("ML","M","M","RF");
	fuzzycontrolD.insert_rule("ML","P","P","RF");
	fuzzycontrolD.insert_rule("ML","L","L","RF");
	fuzzycontrolD.insert_rule("ML","MP","MP","RF");

	// fuzzycontrolD.insert_rule("M","M","M","DT");
	// fuzzycontrolD.insert_rule("P","P","P","DT");
	// fuzzycontrolD.insert_rule("MP","MP","MP","DT");
	// fuzzycontrolD.insert_rule("ML","ML","ML","DF");
	// fuzzycontrolD.insert_rule("L","L","L","DF");

// Define-se a leitura dos sensores do seu sistema
float ErrorInput = -100.0;
float DeltaErrorInput = 0.0;

float min;
char fc1filename[20];



fuzzycontrolD.set_defuzz(CENTEROFAREA);

// Teste para os controles

//min =  navio(fc,1);
//  printf("Minimum Error = %f\n", min);
  fuzzycontrolD.save_m("controlebottom", 0);
}

float rightMotor::makeInference(float input1, float input2, float input3){
	return fuzzycontrolD.make_inference(input1, input2, input3);
}
