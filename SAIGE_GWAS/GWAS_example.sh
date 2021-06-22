#!/bin/bash

#SBATCH --job-name=hosp
#SBATCH --output=hosp.out
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mail-user=wang.lo@wehi.edu.au

working_dir=~/hpc_home/CoVID-19/hosp
# phenotype file generated from COVID19.severity function
pheno_file=~/hpc_home/CoVID-19/April/severity.cov.txt
phe_name=hosp
cov_name=sex,age,bmi,smoke,SES,inAgedCare

ukb_dir=<your UKBB data dir>
data_dir=${working_dir}/data
scripts_dir=${working_dir}/script
saige_dir=${working_dir}/SAIGE

cd ${working_dir}

# ID list
cp $pheno_file ${data_dir}/phe.txt
module load R
Rscript ~/hpc_home/CoVID-19/ID.list.R

## run SAIGE - step 1.
cd ${working_dir}

plink=~/hpc_home/software/plink

$plink --bfile ${ukb_dir}/cleanedEuroData/grmSNPsSubset/grmSNPsEuro \
--keep ${data_dir}/ID.list \
--make-bed \
--out ${data_dir}/grmSNPsSubset/grmSNPEuro

$plink --bfile ${data_dir}/grmSNPsSubset/grmSNPEuro --pca 20 --out ${data_dir}/grmSNPsSubset/pca.20


Rscript ~/hpc_home/CoVID-19/phe.pca.R


## Run!
singularity run ./saige_0.36.3.2.sif step1_fitNULLGLMM.R     \
        --plinkFile=$data_dir/grmSNPsSubset/grmSNPEuro \
        --phenoFile=$data_dir/phe.pca.txt \
        --phenoCol=$phe_name \
        --covarColList=${cov_name},array,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,PC16,PC17,PC18,PC19,PC20 \
        --sampleIDColinphenoFile=ID \
        --traitType=binary       \
        --outputPrefix=${saige_dir}/output/nullModel \
        --nThreads=4 \
        --LOCO=FALSE


# step 2
nCh=$(wc -l ${ukb_dir}/geneticDataCleaning/qcFiles/chunks_minMaf0.0001_minInfo0.8.txt | cut -d " " -f 1)

for ch in $(seq 1 $nCh)
do

  read CHR chunk start end < <(sed -n ${ch}p ${ukb_dir}/geneticDataCleaning/qcFiles/chunks_minMaf0.0001_minInfo0.8.txt)

  echo 'chrom '$CHR' chunk '$chunk' - '$start' to '$end''

  cat <<- EOF > $scripts_dir/runGWAS_chr${CHR}_chunk${chunk}.sh
#!/bin/bash

#SBATCH --job-name=gwas-${CHR}-${chunk}
#SBATCH --output=${saige_dir}/GWAS_ERRORS/CHR${CHR}_chunk${chunk}
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mail-user=wang.lo@wehi.edu.au

module load gcc
module unload singularity
module load singularity/3.3.0

export PATH=\${PATH}:/QCTOOL/qctool_v2.0.1-CentOS6.8-x86_64/:/resources/bgen/gavinband-bgen-44fcabbc5c38/build/apps/

cd ${working_dir}

# copy data to scratch
rsync -av ${ukb_dir}/cleanedEuroData/imputed/cleanedEuro_chr${CHR}_chunk${chunk}.* ${data_dir}/imputed

# filter data to only include those in GWAS
qctool \
      -g ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}.bgen  \
      -s ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}.sample \
      -bgen-bits 8 \
      -incl-samples ${data_dir}/ID.list.new \
      -og ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt.bgen \
      -os ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt.sample

# Remove header from sample file
sed -e '1,2d' ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt.sample > ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt_noHead.sample

# Index bgen file
bgenix -g ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt.bgen -index -clobber

# Run GWAS
singularity run ./saige_0.36.3.2.sif step2_SPAtests.R --bgenFile=${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt.bgen --bgenFileIndex=${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt.bgen.bgi --minMAF=0.01 --minMAC=5 --sampleFile=${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt_noHead.sample --GMMATmodelFile=${saige_dir}/output/nullModel.rda --varianceRatioFile=${saige_dir}/output/nullModel.varianceRatio.txt --SAIGEOutputFile=${saige_dir}/output/chr${CHR}_chunk${chunk}_results.txt --numLinesOutput=2 --IsOutputAFinCaseCtrl=TRUE --IsOutputAFinCaseCtrl=TRUE


# tidy up
rm ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}.*
rm ${data_dir}/imputed/cleanedEuro_chr${CHR}_chunk${chunk}_filt*

EOF

  sbatch $scripts_dir/runGWAS_chr${CHR}_chunk${chunk}.sh
  sleep 5
done

