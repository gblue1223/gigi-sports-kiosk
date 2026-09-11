import { pathToFileURL } from 'node:url';

export function cmsBaseUrl(value) {
  if (!value?.trim()) {
    throw new Error('CMS_BASE_URL is missing. Set it in the Vercel project environment variables and redeploy.');
  }
  let url;
  try { url = new URL(value.trim()); }
  catch { throw new Error('CMS_BASE_URL must be a complete HTTPS URL.'); }
  const local = ['localhost', '127.0.0.1', '[::1]', '10.0.2.2'].includes(url.hostname);
  if (url.protocol !== 'https:' && !(url.protocol === 'http:' && local)) {
    throw new Error('CMS_BASE_URL must use HTTPS (HTTP is allowed only for local development).');
  }
  if (url.username || url.password || url.search || url.hash || url.pathname !== '/') {
    throw new Error('CMS_BASE_URL must contain only the CMS origin, without credentials, an API path, query, or fragment.');
  }
  return url.origin;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { process.stdout.write(cmsBaseUrl(process.env.CMS_BASE_URL)); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
