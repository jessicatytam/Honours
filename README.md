
# :bomb: Task manager

## :pick: Data collection

  - [x] Body mass (5400 spp)
      - [x] EltonTraits 1.0 (will only use this for now)
          - [x] collected
          - [x] cleaned  
            ~~- \[ \] ADW~~  
            ~~- \[x\] scraped~~  
            ~~- \[ \] cleaned~~  
            ~~- \[ \] AnAge~~  
            ~~- \[x\] collected~~  
            ~~- \[ \] cleaned~~  
            ~~- \[ \] PanTheria~~  
            ~~- \[x\] collected~~  
            ~~- \[ \] cleaned~~  
            ~~- \[ \] Smith et al.~~  
            ~~- \[x\] collected~~  
            ~~- \[ \] cleaned~~
  - [x] GBIF geographical location (4721 spp)
  - [x] Phylogeny (6952 spp)
  - [x] Human use (1472 spp)
      - [x] collected from IUCN
      - [x] try pivot\_wider()
  - [x] IUCN status (5934 spp)
      - [x] collected
      - [x] cleaned

## :abacus: Pre-analysis

  - [x] Combine datasets (8308 spp)
  - [x] More cleaning up
      - [x] remove species with only genus or species name (8305 spp)
  - [x] Add classification levels (taxize)
      - will have to come back to do this after itis is working again
  - [x] Synonym matching (rotl)
      - [x] create a species list in long form with the ID
  - [ ] Common name matching (rinat)
      - resolve error “No encoding supplied: defaulting to UTF-8.”
  - [x] *h*-index (specieshindex)
      - [x] put quotation marks around synonyms
      - [x] fix weird NA dataframe (putting synonyms around the synonyms
        seems to have fixed the problem)
      - [x] divide species list into 2 to fix timeout issue
      - [x] run the 2nd list next week since I’ve reached the limit of
        20,000 requests this week
  - [ ] Missing data (mice)
  - [ ] Altmetrics (rAltmetric)
  - [ ] Google Trends (gtrendsR) :round\_pushpin:

## :art: Making graphs :round\_pushpin:

  - [x] h vs mass
  - [x] h vs phylogeny
  - [x] h vs location
  - [x] *h*-index map
  - [x] h vs human use
  - [x] h vs domestication
  - [x] h vs iucn
  - [ ] h with vs without conservation keyword
      - [ ] check for patterns
  - [ ] Google Trends sum, slope, intercept
  - [ ] Google Trends map

## :rocket: Statistical analysis

  - [ ] MCMCglmm
  - [ ] PGLS
  - [ ] Phylogenetic signals (phylosignal)
  - [ ] *h*<sup>2</sup>
  - [ ] Pagel’s λ

 

**Legend**  
What I’m working on now :round\_pushpin:  
Priority :gem:
