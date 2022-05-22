const { Client } = require("@notionhq/client");
const { NotionToMarkdown } = require("notion-to-md");
const {getBlockChildren} = require("notion-to-md/build/utils/notion");
const markdownit = require("markdown-it");

const notion = new Client({
  auth: process.env.NOTION_API_KEY,
  baseUrl: "https://notion-proxy.herokuapp.com/https://api.notion.com",
});

const n2m = new NotionToMarkdown({ notionClient: notion });

const target = document.querySelector("#content");
const spinner = document.querySelector("#spinner");

function renderMarkdown(res) {
    n2m.blocksToMarkdown([...JSON.parse(res)]).then((mdBlocks)=>{
        const mdString = n2m.toMarkdownString(mdBlocks);

        getData.postMessage(mdString); //pass data to dart
    });
}

module.exports = renderMarkdown;
