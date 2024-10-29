# IGV-Screenshooter
This script takes a list of BAM files and a list of genomic positions to automatically take screenshots of in IGV.

## Input files
**positions_file**: a tab separeted file with only two columns and no header. The first column contains the chromose ID as in your reference genome and the second column contain the position in base pair (bp).
\
\
**bam_files_list**: this file as the name and path of your bam files, one bam file per line.

## Usage

#### 1- Log to a terminal with the -X option (ex: ssh -X user@my_address)

#### 2- Run the following command in your local terminal to generate the IGV screenshots
```bash
curl -s https://raw.githubusercontent.com/tomstamour/IGV-Screenshooter/refs/heads/main/IGV-ScreenShooter.sh | bash -s \
/my_own_path/my_positions_file.txt \
/my_own_path/my_bam_files_list.txt \
/my_own_path/my_reference-genome.fa \
/my_own_path/my_output_directory

