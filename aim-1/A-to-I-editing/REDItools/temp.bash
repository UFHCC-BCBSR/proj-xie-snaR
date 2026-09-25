# Deactivate current environment
conda deactivate

# Remove old environment
conda env remove -n reditools

# Create new one with Python 3.10
conda create -n reditools python=3.10

# Activate it
conda activate reditools

# Install dependencies
conda install -c bioconda samtools tabix htslib
conda install pandas numpy matplotlib ipykernel

# Install REDItools3
pip install REDItools3

# Re-register kernel for Jupyter
python -m ipykernel install --user --name=reditools --display-name="Python (reditools)"
