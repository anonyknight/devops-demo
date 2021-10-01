# DevOps Demo

This repo is to demo how DevOps works for open source
[mkdocs sample](https://github.com/giansalex/mkdocs-sample)

## TechStack:

Build markdown files into Static website.
Markdown, HTML, CSS and Javascript.


## Steps:
1. The release notes app use Mkdocs to generate a static website.
2. Call Terraform to deploy this app into GCP.
3. Use docker-compose to run the APP.
4. Use docker-compose to run selenium standalone chrome.
5. Use python selenium to do the sanity tests for the target URL.

## Reference

[Automating Terraform Deployment to Google Cloud with GitHub Actions](https://medium.com/interleap/automating-terraform-deployment-to-google-cloud-with-github-actions-17516c4fb2e5)

[Prism is a lightweight, extensible syntax highlighter, built with modern web standards in mind](https://prismjs.com/)


## Improvement
Investigate how to run db first, then django in terraform.

It keeps complain about permission denied issue.

[Django Docker](https://docs.docker.com/samples/django/)