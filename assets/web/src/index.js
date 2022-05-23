const { Client } = require("@notionhq/client");
const { NotionToMarkdown } = require("notion-to-md");
const { getBlockChildre } = require("notion-to-md/build/utils/notion");

const notion = new Client({
  auth: process.env.NOTION_API_KEY,
  baseUrl: "https://notion-proxy.herokuapp.com/https://api.notion.com",
});

const n2m = new NotionToMarkdown({ notionClient: notion });

function renderMarkdown(pageId) {
  n2m.pageToMarkdown(pageId).then((mdblocks) => {
    console.log(mdblocks);
    const mdString = n2m.toMarkdownString(mdblocks);
    console.log(mdString);
  });
}

module.exports = renderMarkdown;
