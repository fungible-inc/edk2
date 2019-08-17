
FUNDOCKER = ./fun_docker.sh

images = run_funos 
images += $(arg_user)/run_funos 
images += bld_funos 
images += $(arg_user)/bld_funos
images += $(arg_user)/dind
images += run_cclinux
images += integ_test
images += run_sc
images += bld_sc
images += bld_bcm
images += bld_fpga
images += bld_hd

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
bld_funos: run_funos

bld_funos: Dockerfile.bld_funos
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/bld_funos: bld_funos

$(arg_user)/bld_funos: Dockerfile.bld_funos.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# run_cclinux
run_cclinux: Dockerfile.run_cclinux
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# run_sc
run_sc: Dockerfile.run_sc
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/run_sc: run_sc

$(arg_user)/run_sc: Dockerfile.run_sc.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_sc
bld_sc: run_sc

bld_sc: Dockerfile.bld_sc
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/bld_sc: bld_sc

$(arg_user)/bld_sc: Dockerfile.bld_sc.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_fpga
bld_fpga: Dockerfile.bld_fpga
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_bcm
bld_bcm: Dockerfile.bld_bcm
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# bld_hd
bld_hd: Dockerfile.bld_hd
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# dind
$(arg_user)/dind: Dockerfile.dind.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

# test
integ_test: Dockerfile.integ_test
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

