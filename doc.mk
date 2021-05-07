
FUNDOCKER = ./fun_docker.sh

images = run_funos 
images += $(arg_user)/run_funos 
images += bld_funos 
images += $(arg_user)/bld_funos
images += $(arg_user)/dind
images += hiredis_swss
images += nanomsg
images += zmq
images += fun_external
images += run_cclinux
images += $(arg_user)/run_cclinux
images += integ_test
images += bld_bcm
images += bld_insyde
images += $(arg_user)/bld_insyde
images += bld_fpga
images += $(arg_user)/bld_fpga
images += bld_hd
images += bld_golang
images += bld_gccgo
images += bld_apigateway
images += $(arg_user)/bld_fun_on_demand
#images += run_sc
images += bld_sc
images += $(arg_user)/bld_sc
images += fun_debugbase

all: $(images)

clean: 
	/bin/rm -rf *.log $(images) $(arg_user)
	- docker rmi $(images)

# run_funos
run_funos: Dockerfile.run_funos
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/run_funos: run_funos

$(arg_user)/run_funos: Dockerfile.run_funos.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_funos
bld_funos: run_cclinux

bld_funos: Dockerfile.bld_funos
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/bld_funos: bld_funos

$(arg_user)/bld_funos: Dockerfile.bld_funos.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# hiredis_swss
hiredis_swss: Dockerfile.hiredis_swss
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# nanomsg
nanomsg: Dockerfile.nanomsg
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# zmq
zmq: Dockerfile.zmq
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# fun_external
fun_external: Dockerfile.fun_external
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# run_cclinux

run_cclinux: run_funos hiredis_swss nanomsg zmq fun_external

run_cclinux: Dockerfile.run_cclinux
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/run_cclinux: run_cclinux

$(arg_user)/run_cclinux: Dockerfile.run_cclinux.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<


# run_sc
run_sc: Dockerfile.run_sc
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_sc
bld_sc: 

bld_sc: Dockerfile.bld_sc
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/bld_sc: bld_sc

$(arg_user)/bld_sc: Dockerfile.bld_sc.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_fpga
bld_fpga: Dockerfile.bld_fpga
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/bld_fpga: bld_fpga

$(arg_user)/bld_fpga: Dockerfile.bld_fpga.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_bcm
bld_bcm: Dockerfile.bld_bcm
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_insyde
bld_insyde: Dockerfile.bld_insyde
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/bld_insyde: bld_insyde

$(arg_user)/bld_insyde: Dockerfile.bld_insyde.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_hd
bld_hd: Dockerfile.bld_hd
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_golang
bld_golang: Dockerfile.bld_golang
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_gccgo
bld_gccgo: Dockerfile.bld_gccgo
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# Fun-on-demand build and test.
$(arg_user)/bld_fun_on_demand: Dockerfile.bld_fun_on_demand.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# dind
$(arg_user)/dind: Dockerfile.dind.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# test
integ_test: Dockerfile.integ_test
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_apigateway
bld_apigateway: Dockerfile.bld_apigateway
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# fun_debugbase
fun_debugbase: Dockerfile.fun_debugbase
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

