const { Client } = require("@notionhq/client");
const { NotionToMarkdown } = require("notion-to-md");
const markdownit = require("markdown-it");

const notion = new Client({
  auth: process.env.NOTION_API_KEY,
  baseUrl: "https://notion-proxy.herokuapp.com/https://api.notion.com",
});

const n2m = new NotionToMarkdown({ notionClient: notion });

const target = document.querySelector("#content");

function renderMarkdown(pageId) {
  n2m.pageToMarkdown(pageId).then((mdblocks) => {
    const mdString = n2m.toMarkdownString(mdblocks);
    target.innerHTML = markdownit().render(mdString);
  });
}

module.exports = renderMarkdown;
