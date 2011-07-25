/*
  IOexpander.cpp
  12-02-2011
  Copyright (c) 2011 Koen Warffemius.  All right reserved. www.koenwar.nl

 +This class provides a easy to use interface to a MCP23016 i2c Pin expander.
 +The MCP23016 provides 16 digital IO ports.
 +The interface of this class looks as much the same as the default IO functions of the arduino
 +This class uses the Wire librarie for the i2c communication.
 
  versions:
  08-02-2011 – start of the project
  19-02-2011 – v0.2 intial release
  20-02-2011 - v0.3 improvements submitted by robtillaart, support added for the MCP23017 and MCP23018 (not tested yet)
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/


#include <IOexpander.h>
#include <Wire.h>
#include "WProgram.h"


// Constructors ////////////////////////////////////////////////////////////////

IOexpander::IOexpander()
{
}

// Public Methods //////////////////////////////////////////////////////////////

bool IOexpander::init(uint8_t address, uint8_t device_type)
{
  switch(device_type){
	case 1:
		REGISTER_GP0 = 0x00;
		REGISTER_IODIR0 = 0x06;
		break;
	case 2 ... 3:
		REGISTER_GP0 = 0x12;
		REGISTER_IODIR0 = 0x00;
		break;
	default:
		return false;
  }
  addr = address;
  port0 = ALL_LOW;
  port1 = ALL_LOW;
  regPort0 = ALL_INPUT;
  regPort1 = ALL_INPUT;
  
  Wire.begin();

  pinModePort(0,INPUT);
  pinModePort(0,INPUT);
  return refresh();
}


bool IOexpander::pinMode(uint8_t port,uint8_t pin, bool mode)
{
  if(port > 1 || pin > 7) return false;
  uint8_t temp = 0;

  if(!mode){
	//pin setup as input = 1
	temp = 1 << pin;
	if(port == 0)
		regPort0 |= temp;
	else
		regPort1 |= temp;
  }else{
	//pin setup as output 0
	temp = 1 << pin;
	temp = ~temp;
	if(port == 0)
		regPort0 &= temp;
	else
		regPort1 &= temp;
  }
  
  //send new config to IODIR0 and 1
  Wire.beginTransmission(addr);  	// START TRANSMISSION
  Wire.send(REGISTER_IODIR0); 		// SELECT REGISTER_IODIR0
  Wire.send(regPort0);  			// DDR Port0 IODIR0
  Wire.send(regPort1);  			// DDR Port1 IODIR1
  if(Wire.endTransmission() == 0)
	return true;
  else
	return false;
}

bool IOexpander::pinModePort(uint8_t port, bool mode)
{
  if(port > 1) return false; // we only have two ports
  
  if(!mode){
	//DDR as input = 1
	if(port == 0)
		regPort0 = ALL_INPUT;
	else
		regPort1 = ALL_INPUT;
  }else{
	//DDR as output 0
	if(port == 0)
		regPort0 = ALL_OUTPUT;
	else
		regPort1 = ALL_OUTPUT;
  }
  
  //send new config to IODIR REGISTER
  Wire.beginTransmission(addr);  	// START TRANSMISSION
  Wire.send(REGISTER_IODIR0); 		// SELECT REGISTER_IODIR0
  Wire.send(regPort0);  			// DDR Port0 IODIR0
  Wire.send(regPort1);  			// DDR Port1 IODIR1
  if(Wire.endTransmission() == 0)
	return true;
  else
	return false;
}

bool IOexpander::digitalWritePort(uint8_t port, bool value){
	//check if all the pins are outputs
	if(port > 1) return false; //we only got two ports
	
	if(port == 0){
		if(regPort0 != B00000000) return false; //if a pin in the regPort0 register is HIGH its a input and we return false;
	}else{
		if(regPort1 != B00000000) return false; //if a pin in the regPort1 register is HIGH its a input and we return false;
	}
	
	if(value){
		//set al pins of this port high
		if(port == 0)port0 = ALL_HIGH;
		else port1 = ALL_HIGH;
	}else{
		if(port == 0)port0 = ALL_LOW ;
		else port1 = ALL_LOW;
	}
	return sendData();
}
		
		

bool IOexpander::digitalWrite(uint8_t port,uint8_t pin, bool value)
{
	uint8_t temp = 0;

	if(port > 1 || pin > 7) return false;
	//check if we are dealing with a output pin
	temp = 1 << pin;
	if(port == 0){
		if(regPort0 & temp == 0) return false; //if the pin in the regPort0 register is low its a input and we return false;
	}else{
		if(regPort1 & temp == 0) return false; //if the pin in the regPort1 register is low its a input and we return false;
	}
	
	if(value){
		//set HIGH = 1;
		temp = 1 << pin;
		if(port == 0)
			port0 |= temp;
		else
			port1 |= temp;
	}else{
		temp = 1 << pin;
		temp = ~temp;
		if(port == 0)
			port0 &= temp;
		else
			port1 &= temp;
	}	
	return sendData();
}

int IOexpander::digitalRead(uint8_t port,uint8_t pin)
{
	uint8_t temp = 0;
	if(port > 1 || pin > 7) return LOW;
	refresh();
	
	temp = 1 << pin;
	if(port == 0){
		if((port0 & temp) == temp) return HIGH; //if the pin in the port0 register is high we return HIGH;
	}else{
		if((port1 & temp) == temp) return HIGH; //if the pin in the port1 register is high we return HIGH;
	}
	return LOW;
} 

bool IOexpander::sendData()
{
  Wire.beginTransmission(addr);
  Wire.send(REGISTER_GP0); 	//select General purpose register
  Wire.send(port0); 		//write to REGISTER_GP0
  Wire.send(port1); 		//write to REGISTER_GP1
  if(Wire.endTransmission() == 0)
	return true;
  else
	return false;
}



bool IOexpander::refresh()
{
  Wire.beginTransmission(addr);
    Wire.send(REGISTER_GP0); //select General purpose register
  if(Wire.endTransmission() > 0) return false;
  
  Wire.requestFrom(addr, (uint8_t)2); //request two bytes, register gp1 and 1-2
    if(Wire.available() == 2){
		port0 = Wire.receive();  //recv REGISTER_GP0
		port1 = Wire.receive();  //recv REGISTER_GP1
		return true;
	}else
		return false;
}