# Build kraken2 & Bracken test database

Use the test genomes to create a
[kraken2](https://github.com/DerrickWood/kraken2) database and
[bracken](https://github.com/jenniferlu717/Bracken) classifier mappings for
different expected read lengths.

## Usage

1. Set up nextflow as [described
   here](https://www.nextflow.io/index.html#GetStarted).
2. If you didn't run this pipeline in a while, possibly update nextflow itself.
   ```
   nextflow self-update
   ```
3. Then run the pipeline.
   ```
   nextflow -c anton.config run main.nf -profile docker
   ```

## Copyright

- Copyright © 2022, Moritz E. Beber.
- Free software, distributed under the [MIT license](LICENSE)
