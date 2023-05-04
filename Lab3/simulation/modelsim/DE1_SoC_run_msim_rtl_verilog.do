transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab3 {C:/Users/noah-/Documents/EE-CSE-469/Lab3/hazardmodule.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab3 {C:/Users/noah-/Documents/EE-CSE-469/Lab3/FlagsReg.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab1 {C:/Users/noah-/Documents/EE-CSE-469/Lab1/reg_file.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab1 {C:/Users/noah-/Documents/EE-CSE-469/Lab1/fullAdder.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab1 {C:/Users/noah-/Documents/EE-CSE-469/Lab1/ttLogic.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab3 {C:/Users/noah-/Documents/EE-CSE-469/Lab3/top.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab3 {C:/Users/noah-/Documents/EE-CSE-469/Lab3/dmem.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab3 {C:/Users/noah-/Documents/EE-CSE-469/Lab3/arm.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab3 {C:/Users/noah-/Documents/EE-CSE-469/Lab3/Mux2x1.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab1 {C:/Users/noah-/Documents/EE-CSE-469/Lab1/ALU.sv}
vlog -sv -work work +incdir+C:/Users/noah-/Documents/EE-CSE-469/Lab3 {C:/Users/noah-/Documents/EE-CSE-469/Lab3/imem.sv}

