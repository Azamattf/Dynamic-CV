-- Global variables to track overflow
has_overflow = false
overflow_sections = {}

-- Function to process sections based on the column
function process_sections(sections_csv, column)
  -- Load sections data
  local sections_data = load_csv_data(sections_csv)
  
  for i, section in ipairs(sections_data) do
    -- Check if this section should be displayed in the current column
    if tonumber(section.column) == column and section.display == "yes" then
      -- Process the section
      process_section(section.name, section.csv_file, false)
    end
  end
end

-- Function to process overflow sections
function process_overflow_sections(column)
  for _, section in ipairs(overflow_sections) do
    if tonumber(section.column) == column then
      process_section(section.name, section.csv_file, true)
    end
  end
end

-- Function to process a specific section
function process_section(section_name, csv_file, is_overflow)
  local section_type = string.lower(section_name:gsub("%s+", ""))
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
  
  -- Process the section content based on type
  if section_type == "personalinfo" then
    format_personal_info("data/" .. csv_file)
  elseif section_type == "summary" then
    format_summary("data/" .. csv_file)
  elseif section_type == "workexperience" then
    format_timeline("data/" .. csv_file, is_overflow)
  elseif section_type == "education" then
    format_timeline("data/" .. csv_file, is_overflow)
  elseif section_type == "educationnonformal" then
    format_timeline("data/" .. csv_file, is_overflow)
  elseif section_type == "fieldlab" then
    format_timeline("data/" .. csv_file, is_overflow)
  elseif section_type == "skills" then
    format_skills("data/" .. csv_file)
  elseif section_type == "awards" then
    format_awards("data/" .. csv_file, is_overflow)
  elseif section_type == "projects" then
    format_projects("data/" .. csv_file, is_overflow)
  elseif section_type == "volunteering" then
    format_timeline("data/" .. csv_file, is_overflow)
  elseif section_type == "publications" then
    format_publications("data/" .. csv_file, is_overflow)
  elseif section_type == "hobbies" then
    format_summary("data/" .. csv_file)
  elseif section_type == "jobspecific" then
    format_summary("data/" .. csv_file)
  end
  
  tex.print("\\end{minipage}")
  tex.print("\\end{lrbox}")
  
  -- Get the height variable
  local height_var = "\\defaultsectionheight"
  if tex.isdefine(section_height_var) == 1 then
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
    if section.name == section_name then
      return section.column
    end
  end
  
  return 1 -- Default to first column if not found
end

-- Load CSV data into a Lua table
function load_csv_data(file_path)
  local data = {}
  local file = io.open(file_path, "r")
  
  if not file then
    return data
  end
  
  -- Read header line and parse column names
  local header = file:read()
  local columns = {}
  for col in header:gmatch("([^,]+)") do
    table.insert(columns, col:gsub("^%s*(.-)%s*$", "%1")) -- Trim whitespace
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
  
  file:close()
  return data
end

-- Format personal information
function format_personal_info(csv_file)
  local data = load_csv_data(csv_file)
  
  if #data < 1 then return end
  local info = data[1]
  
  -- Name and title
  tex.print("\\begin{center}")
  tex.print("\\textcolor{\\primarycolor}{\\Huge\\textbf{" .. info.name .. "}}")
  tex.print("\\\\[0.2cm]")
  tex.print("\\Large " .. info.title)
  tex.print("\\end{center}")
  tex.print("\\vspace{0.5cm}")
  
  -- Contact information with icons
  if info.address and info.address ~= "" then
    tex.print("\\infoitem{\\faMapMarker}{" .. info.address .. "}")
  end
  
  if info.email and info.email ~= "" then
    tex.print("\\infoitem{\\faEnvelope}{\\href{mailto:" .. info.email .. "}{" .. info.email .. "}}")
  end
  
  if info.phone and info.phone ~= "" then
    tex.print("\\infoitem{\\faPhone}{" .. info.phone .. "}")
  end
  
  if info.website and info.website ~= "" then
    tex.print("\\infoitem{\\faGlobe}{\\href{" .. info.website .. "}{" .. info.website .. "}}")
  end
  
  if info.linkedin and info.linkedin ~= "" then
    tex.print("\\infoitem{\\faLinkedin}{\\href{" .. info.linkedin .. "}{LinkedIn}}")
  end
  
  if info.github and info.github ~= "" then
    tex.print("\\infoitem{\\faGithub}{\\href{" .. info.github .. "}{GitHub}}")
  end
  
  if info.twitter and info.twitter ~= "" then
    tex.print("\\infoitem{\\faTwitter}{\\href{" .. info.twitter .. "}{Twitter}}")
  end
end

-- Format summary sections
function format_summary(csv_file)
  local data = load_csv_data(csv_file)
  
  for _, entry in ipairs(data) do
    tex.print("\\summaryentry{" .. entry.content .. "}")
  end
end

-- Format timeline entries (work experience, education, etc.)
function format_timeline(csv_file, is_overflow)
  local data = load_csv_data(csv_file)
  
  -- Sort by start date (newest first)
  table.sort(data, function(a, b) 
    return a.start_date > b.start_date 
  end)
  
  for _, entry in ipairs(data) do
    local end_date = entry.end_date
    if end_date == "present" or end_date == "Present" then
      end_date = "Present"
    end
    
    tex.print("\\timelineentry{" .. 
      entry.start_date .. "}{" .. 
      end_date .. "}{" .. 
      entry.title .. "}{" .. 
      entry.organization .. "}{" .. 
      entry.description .. "}")
  end
end

-- Format skills with level bars
function format_skills(csv_file)
  local data = load_csv_data(csv_file)
  
  -- Sort by skill level (highest first)
  table.sort(data, function(a, b) 
    return tonumber(a.level) > tonumber(b.level) 
  end)
  
  for _, skill in ipairs(data) do
    -- Normalize level to 0-1 range
    local level = tonumber(skill.level) / 5.0
    if level > 1.0 then level = 1.0 end
    if level < 0.0 then level = 0.0 end
    
    tex.print("\\skillbar{" .. skill.skill .. "}{" .. level .. "}")
  end
end

-- Format awards
function format_awards(csv_file, is_overflow)
  local data = load_csv_data(csv_file)
  
  -- Sort by year (newest first)
  table.sort(data, function(a, b) 
    return a.year > b.year 
  end)
  
  for _, award in ipairs(data) do
    tex.print("\\awardentry{" .. 
      award.year .. "}{" .. 
      award.title .. "}{" .. 
      award.organization .. "}")
  end
end

-- Format publications
function format_publications(csv_file, is_overflow)
  local data = load_csv_data(csv_file)
  
  -- Sort by year (newest first)
  table.sort(data, function(a, b) 
    return a.year > b.year 
  end)
  
  for _, pub in ipairs(data) do
    tex.print("\\publicationentry{" .. 
      pub.year .. "}{" .. 
      pub.title .. "}{" .. 
      pub.journal .. "}{" .. 
      pub.authors .. "}")
  end
end

-- Format projects
function format_projects(csv_file, is_overflow)
  local data = load_csv_data(csv_file)
  
  -- Sort by year (newest first)
  table.sort(data, function(a, b) 
    return a.year > b.year 
  end)
  
  for _, project in ipairs(data) do
    tex.print("\\projectentry{" .. 
      project.year .. "}{" .. 
      project.title .. "}{" .. 
      project.description .. "}")
  end
end