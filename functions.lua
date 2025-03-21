-- Global variables to track overflow
has_overflow = false
overflow_sections = {}

-- URL mapping for CSV files
csv_urls = {
  ["sections.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=2104570387&single=true&output=csv",
  ["personal_info.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=167211696&single=true&output=csv",
  ["summary.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=1531448452&single=true&output=csv",
  ["job_specific.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=1714925551&single=true&output=csv",
  ["work_experience.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=1355823307&single=true&output=csv",
  ["education.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=470808040&single=true&output=csv",
  ["education_non-formal.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=850872146&single=true&output=csv",
  ["field_lab.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=693445503&single=true&output=csv",
  ["skills.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=1495368041&single=true&output=csv",
  ["projects.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=1291971909&single=true&output=csv",
  ["awards.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=301030244&single=true&output=csv",
  ["publications.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=269738174&single=true&output=csv",
  ["volunteering.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=956232865&single=true&output=csv",
  ["hobbies.csv"] = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQD7KnMwpwoGatJiek81iNwLxV8_upwS854scKX-0QPvbtiw_I-5rylU353MXaUKS_Eg89dxZ_R_e9Q/pub?gid=985610371&single=true&output=csv"
}

-- Function to ensure data directory exists
local lfs = require("lfs") -- LuaFileSystem

function ensure_data_directory()
    local folder = "data"

    -- Check if folder exists
    local attr = lfs.attributes(folder)
    if attr and attr.mode == "directory" then
        return  -- Folder exists, do nothing
    end

    -- Create the folder (Windows & Linux compatible)
    local cmd = string.format('mkdir "%s"', folder)
    os.execute(cmd)
end

-- Call the function before using the data folder
ensure_data_directory()



-- Function to download a file from URL and save it to a local path
function download_file(url, local_path)
  local cmd = string.format('curl -s -L -o %q %q', local_path, url)
  local success = os.execute(cmd)
  
  if success then
    return true
  else
    io.stderr:write("Error: Failed to download file " .. url .. "\n")
    return false
  end
end


-- Function to fetch all required CSV files from URLs
function fetch_csv_files()
  ensure_data_directory()
  
  -- First, fetch the sections.csv file
  if not download_file(csv_urls["sections.csv"], "data/sections.csv") then
    io.stderr:write("Failed to download sections.csv, cannot continue\n")
    return false
  end
  
  -- Load the sections.csv to determine which other files we need
  local sections_data = load_csv_data("data/sections.csv")
  
  -- Track which files we've already downloaded
  local downloaded_files = {["sections.csv"] = true}
  
  -- Download each section's CSV file
  for _, section in ipairs(sections_data) do
    if section.csv_file and not downloaded_files[section.csv_file] then
      local url = csv_urls[section.csv_file]
      if url then
        download_file(url, "data/" .. section.csv_file)
        downloaded_files[section.csv_file] = true
      else
        io.stderr:write("Warning: No URL defined for " .. section.csv_file .. "\n")
      end
    end
  end
  
  return true
end

-- Function to process sections based on the column
function process_sections(sections_csv, column)
  -- First fetch all CSV files
  fetch_csv_files()
  
  -- Load sections data
  local sections_data = load_csv_data(sections_csv)
  
  for i, section in ipairs(sections_data) do
    -- Check if this section should be displayed in the current column
    if tonumber(section.Column) == column and section.Display == "TRUE" then
      -- Process the section
      process_section(section.Section, section.csv_file, false)
    end
  end
end

-- Function to process overflow sections
function process_overflow_sections(column)
  for _, section in ipairs(overflow_sections) do
    if tonumber(section.Column) == column then
      process_section(section.Section, section.csv_file, true)
    end
  end
end

-- Function to process a specific section
function process_section(section_name, csv_file, is_overflow)
  local section_type = string.lower(section_name:gsub("%s+", ""):gsub("%W", ""))
  local section_height_var = section_type .. "sectionheight"
  
  -- Print section header
  if is_overflow then
    tex.print("\\overflowsectionheader{" .. section_name .. "}")
  else
    tex.print("\\sectionheader{" .. section_name .. "}")
  end
  
  -- Begin a box to measure content
  tex.print("\\begin{lrbox}{\\measurebox}")
  tex.print("\\begin{minipage}{\\columnwidth}")
  
  -- Process the section content using csvsimple
  if section_type == "personalinfo" then
    process_personal_info("data/" .. csv_file)
  elseif section_type == "summary" then
    process_summary("data/" .. csv_file)
  elseif section_type == "workexperience" then
    process_timeline("data/" .. csv_file, is_overflow, "work")
  elseif section_type == "education" then
    process_timeline("data/" .. csv_file, is_overflow, "education")
  elseif section_type == "educationnonformal" then
    process_timeline("data/" .. csv_file, is_overflow, "education")
  elseif section_type == "fieldlab" then
    process_timeline("data/" .. csv_file, is_overflow, "fieldlab")
  elseif section_type == "skills" then
    process_skills("data/" .. csv_file)
  elseif section_type == "awards" then
    process_awards("data/" .. csv_file, is_overflow)
  elseif section_type == "projects" then
    process_projects("data/" .. csv_file, is_overflow)
  elseif section_type == "volunteering" then
    process_timeline("data/" .. csv_file, is_overflow, "volunteer")
  elseif section_type == "publications" then
    process_publications("data/" .. csv_file, is_overflow)
  elseif section_type == "hobbies" then
    process_summary("data/" .. csv_file)
  elseif section_type == "jobspecific" then
    process_summary("data/" .. csv_file)
  end
  
  tex.print("\\end{minipage}")
  tex.print("\\end{lrbox}")
  
  -- Get the height variable
  local height_var = "\\defaultsectionheight"
  local is_defined = pcall(function() return token.get_macro(section_height_var) end)
  if is_defined then
    height_var = "\\" .. section_height_var
  end
  
  -- Check if content overflows the specified section height
  tex.print("\\newdimen\\contentht")
  tex.print("\\contentht=\\ht\\measurebox")
  tex.print("\\advance\\contentht by \\dp\\measurebox")
  
  -- If the content fits, just output it
  tex.print("\\ifdim\\contentht<" .. height_var .. "cm")
  tex.print("  \\usebox{\\measurebox}")
  tex.print("\\else")
  
  -- Otherwise, clip to the height and mark as overflowed for next page
  tex.print("  \\begin{minipage}[c][" .. height_var .. "cm][t]{\\columnwidth}")
  tex.print("    \\usebox{\\measurebox}")
  tex.print("  \\end{minipage}")
  
  -- Only mark overflow if this isn't already an overflow section
  if not is_overflow then
    tex.print("  \\directlua{has_overflow = true}")
    tex.print("  \\directlua{table.insert(overflow_sections, {name='" .. 
              section_name .. "', csv_file='" .. csv_file .. "', column=" .. 
              get_section_column(section_name) .. "})}")
  end
  
  tex.print("\\fi")
end

-- Get section column number
function get_section_column(section_name)
  local sections_data = load_csv_data("data/sections.csv")
  
  for _, section in ipairs(sections_data) do
    if section.Section == section_name then
      return section.Column
    end
  end
  
  return 1 -- Default to first column if not found
end

-- Simplified CSV loading function (needed for sections.csv to determine which files to download)
function load_csv_data(file_path)
  local data = {}
  local file = io.open(file_path, "r")
  
  if not file then
    return data
  end
  
  -- Read header line and parse column names
  local header = file:read()
  local columns = {}
  
  -- Handle the case of a single-column CSV (no commas)
  if not header:find(",") then
    -- If there's no comma, treat the whole line as a single column name
    header = header:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    table.insert(columns, header)
    
    -- Read each line as a single-value row
    for line in file:lines() do
      local value = line:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
      local row = {}
      row[header] = value
      table.insert(data, row)
    end
  else
    -- Multi-column case - original implementation
    for col in header:gmatch("([^,]+)") do
      table.insert(columns, (col:gsub("^%s*(.-)%s*$", "%1"))) -- Trim whitespace
    end
    
    -- Read data lines
    for line in file:lines() do
      local row = {}
      local i = 1
      for value in line:gmatch("([^,]+)") do
        row[columns[i]] = value:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
        i = i + 1
      end
      table.insert(data, row)
    end
  end
  
  file:close()
  return data
end

-- Function to update URL mapping for CSV files
function set_csv_url(filename, url)
  csv_urls[filename] = url
end

-- The following functions now use csvsimple instead of directly parsing CSV data

-- Process personal information using csvsimple
function process_personal_info(csv_file)
  local rel_path = csv_file:gsub("^data/", "")
  tex.print("\\begin{center}")
  tex.print("\\csvreader[head to column names]{" .. csv_file .. "}{}{%")
  tex.print("  \\textcolor{\\primarycolor}{\\Huge\\textbf{\\name}}\\\\[0.2cm]")
  tex.print("  \\Large \\title")
  tex.print("}") -- End of csvreader
  tex.print("\\end{center}")
  tex.print("\\vspace{0.5cm}")

  -- Contact information with icons
  tex.print("\\csvreader[head to column names]{" .. csv_file .. "}{}{%")
  
  -- Only output non-empty fields
  tex.print("  \\ifcsvnotequals{address}{}%")
  tex.print("    {\\infoitem{\\faMapMarker}{\\address}}%")
  tex.print("  \\fi")
  
  tex.print("  \\ifcsvnotequals{email}{}%")
  tex.print("    {\\infoitem{\\faEnvelope}{\\href{mailto:\\email}{\\email}}}%")
  tex.print("  \\fi")
  
  tex.print("  \\ifcsvnotequals{phone}{}%")
  tex.print("    {\\infoitem{\\faPhone}{\\phone}}%")
  tex.print("  \\fi")
  
  tex.print("  \\ifcsvnotequals{website}{}%")
  tex.print("    {\\infoitem{\\faGlobe}{\\href{\\website}{\\website}}}%")
  tex.print("  \\fi")
  
  tex.print("  \\ifcsvnotequals{linkedin}{}%")
  tex.print("    {\\infoitem{\\faLinkedin}{\\href{\\linkedin}{LinkedIn}}}%")
  tex.print("  \\fi")
  
  tex.print("  \\ifcsvnotequals{github}{}%")
  tex.print("    {\\infoitem{\\faGithub}{\\href{\\github}{GitHub}}}%")
  tex.print("  \\fi")
  
  tex.print("  \\ifcsvnotequals{twitter}{}%")
  tex.print("    {\\infoitem{\\faTwitter}{\\href{\\facebook}{Facebook}}}%")
  tex.print("  \\fi")
  
  tex.print("}") -- End of csvreader
end

-- Process summary sections using csvsimple
function process_summary(csv_file)
  tex.print("\\csvreader[head to column names]{" .. csv_file .. "}{}%")
  tex.print("{\\summaryentry{\\content}}")
end

-- Process timeline entries using csvsimple
function process_timeline(csv_file, is_overflow, entry_type)
  -- Use csvsimple with sort key to sort by Year_finish (newest first)
  tex.print("\\csvreader[")
  tex.print("  sort by=Year_finish,") 
  tex.print("  sort reverse,") 
  tex.print("  head to column names")
  tex.print("]{" .. csv_file .. "}{}%")
  tex.print("{%")
  tex.print("  \\timelineentry{%")
  tex.print("    \\csvcoli}{%") -- start_date
  
  -- Format Year_finish, convert "present" to "Present"
  tex.print("    \\ifcsvstrcmp{\\Year_finish}{present}{Present}{\\ifcsvstrcmp{\\Year_finish}{Present}{Present}{\\Year_finish}}}{%")
  
  tex.print("    \\Title}{%")
  tex.print("    \\Organization}{%")
  tex.print("    \\Description}%")
  tex.print("}")
end

-- Process skills using csvsimple
function process_skills(csv_file)
  -- Sort by skill level (highest first)
  tex.print("\\csvreader[")
  tex.print("  sort by=Level,") -- Sort by level
  tex.print("  sort reverse,") -- Reverse sort (highest first)
  tex.print("  head to column names")
  tex.print("]{" .. csv_file .. "}{}%")
  tex.print("{%")
  tex.print("  \\skillbar{\\Skill}{%")
  
  -- Normalize level to 0-1 range
  tex.print("    \\fpeval{min(max(\\Level/10,0),1)}%")
  tex.print("  }%")
  tex.print("}")
end

-- Process awards using csvsimple
function process_awards(csv_file, is_overflow)
  -- Sort by year (newest first)
  tex.print("\\csvreader[")
  tex.print("  sort by=Year,") -- Sort by year
  tex.print("  sort reverse,") -- Reverse sort (newest first)
  tex.print("  head to column names")
  tex.print("]{" .. csv_file .. "}{}%")
  tex.print("{%")
  tex.print("  \\awardentry{\\Year}{\\Title}{\\Organization}%")
  tex.print("}")
end

-- Process publications using csvsimple
function process_publications(csv_file, is_overflow)
  -- Sort by year (newest first)
  tex.print("\\csvreader[")
  tex.print("  sort by=Year,") -- Sort by year
  tex.print("  sort reverse,") -- Reverse sort (newest first)
  tex.print("  head to column names")
  tex.print("]{" .. csv_file .. "}{}%")
  tex.print("{%")
  tex.print("  \\publicationentry{\\Year}{\\Title}{\\Journal}{\\Authors}%")
  tex.print("}")
end

-- Process projects using csvsimple
function process_projects(csv_file, is_overflow)
  -- Sort by year (newest first)
  tex.print("\\csvreader[")
  tex.print("  sort by=Year_finish,") -- Sort by year
  tex.print("  sort reverse,") -- Reverse sort (newest first)
  tex.print("  head to column names")
  tex.print("]{" .. csv_file .. "}{}%")
  tex.print("{%")
  tex.print("  \\projectentry{\\Year_finish}{\\Title}{\\Description}%")
  tex.print("}")
end