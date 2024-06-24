# Chameleon Technical Exercise: Request processing
Link to the [technical exercise](https://gist.github.com/bnorton/fbaa35d301138fbdf2ba0d095ebd1c1b)

## Requirements
- Ruby (version >= 2.0)
- Bundler gem

## Installation
1. Clone the repository: `git clone https://github.com/christinema825/Chameleon.git` or download the script (requests.rb)
2. Navigate to the directory containing `requests.rb`
3. Install dependencies: `bundle install`

## Usage
1. Ensure internet connection since the CSV data is download from AWS
2. Run the script: `ruby requests.rb`
3. The script will:
  - Download the CSV data.
  - Calculate the average response time.
  - Determine the number of unique users online.
  - Identify the IDs of the 5 slowest requests.
  - Identify the user overusing the system.
  - Analyze the distribution of request methods.
  - Provide insights based on the most requested method.
  - Maintain a running list of the top 10 slowest requests.
