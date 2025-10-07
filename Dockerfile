# Start with a base R image suitable for Shiny apps
FROM rocker/shiny:4.4.1

# 1. Install ESSENTIAL system dependencies
# These libraries are commonly needed for packages that handle graphics (cairo),
# XML, SSL, and network requests.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    # Standard dependencies
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    # *** CRITICAL: Graphics dependencies for plotting packages like soiltexture ***
    libcairo2-dev \
    libxt-dev \
    # Clean up to keep the image small
    && rm -rf /var/lib/apt/lists/*

# 2. Install R packages from CRAN
# This step MUST run AFTER the system dependencies are installed.
RUN R -e "install.packages(c('shiny', 'soiltexture', 'shinythemes'), repos='https://cran.rstudio.com/')"

# 3. Copy the application file
COPY app.R /srv/shiny-server/

# 4. Set the port (Shiny default)
EXPOSE 3838
