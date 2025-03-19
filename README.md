# Dynamic-CV
This LaTeX code will create a modern CV in PDF dynamically fetching CSV data from Google Sheets. On Google Sheets, one can toggle rows on and off (checkboxes) to show or hide them on the CV. I created this for myself so currently there is only one style, but the sections are customizable. Each CV section gets data from a separate CSV file.

Let us create my cv using csv files from urls. We will use LuaLaTeX in vs code. Here are the requirements. decide the optimal number of files and generate them separately. Source files are to be organized in the "data" folder.  


- Structure should be customizable
- For each section I have a csv data: Personal Info, Summary, Job Specific, WorkExperience, Education, Education_NonFormal, Field/Lab, Skills, Awards, Projects, Volunteering, Publications, Hobbies
- there is also a csv that contains the list of section names, and which sections should be shown.
- Entire document must have two columns, column width ratio and which section goes to which column should be customizable
- Skills include skill level data, which should be visualized as bars or similar.
- Height of each section should be customizable.
- The data shown should be shown in a chronological order, if there is date data
- The number of csv rows shown in each section should be limited by the section area
- Information that did not fit the first page should go to a similar section on next page called something like "extra" or "additional", or "further" (you can be creative in naming).
- section formatting should be consistent throughout the document.
- the left column should be the narrower one with color accent
- three colors should be used in the entire document, which should be customizable, it should not look flamboyant though.
- icons/symbols should be used wherever they fit (symbols for location, social media, telephone, email, etc).