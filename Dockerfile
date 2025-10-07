# Start with a base R image suitable for Shiny apps
FROM rocker/shiny:4.4.1

# 1. Install necessary system dependencies
# These libs (like libgdal, libproj, libcairo) are often needed for graphics and geo-packages like soiltexture.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libcairo2-dev \
    libxt-dev \
    libgdal-dev \
    libproj-dev \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# 2. Install R packages from CRAN
# The packages: shiny, soiltexture, shinythemes
RUN R -e "install.packages(c('shiny', 'soiltexture', 'shinythemes'), repos='https://cran.rstudio.com/')"

# 3. Copy the application file
COPY app.R /srv/shiny-server/

# 4. Set the port (Shiny default)
EXPOSE 3838
