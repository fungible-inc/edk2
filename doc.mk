
FUNDOCKER = fun_docker.sh

images = run_funos 
images += $(arg_user)/run_funos 
images += bld_funos 
images += $(arg_user)/bld_funos
images += dind_funcp
#images += $(arg_user)/bld_sbp

all: $(images)

clean: 
	/bin/rm -rf *.log $(images) $(arg_user)
	- docker rmi $(images)

run_funos: Dockerfile.run_funos
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/run_funos: run_funos

$(arg_user)/run_funos: Dockerfile.run_funos.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

bld_funos: run_funos

bld_funos: Dockerfile.bld_funos
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

$(arg_user)/bld_funos: bld_funos

$(arg_user)/bld_funos: Dockerfile.bld_funos.usr
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

dind_funcp: Dockerfile.dind_funcp
	$(FUNDOCKER) -a $(ACTION) -i $@ -f $<

