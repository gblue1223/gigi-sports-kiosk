import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { cmsBaseUrl } from './cms-build-config.mjs';

const root = fileURLToPath(new URL('../', import.meta.url));

test('validates the CMS origin and normalizes whitespace', () => {
  assert.equal(cmsBaseUrl(' https://cms.gigi-sports.com/\n'), 'https://cms.gigi-sports.com');
  assert.equal(cmsBaseUrl('http://localhost:5173'), 'http://localhost:5173');
  for (const value of [undefined, '', '  ']) assert.throws(() => cmsBaseUrl(value), /missing/);
  for (const value of ['cms.gigi-sports.com', 'http://cms.gigi-sports.com', 'javascript:alert(1)',
    'https://name:password@cms.example', 'https://cms.example/api', 'https://cms.example/?token=private',
    'https://cms.example/#fragment']) assert.throws(() => cmsBaseUrl(value));
});

test('Vercel build forwards its environment to Dart and fails before building without a URL', async () => {
  const bash = process.env.BASH_BIN ?? (process.platform === 'win32' ? 'C:/Program Files/Git/bin/bash.exe' : 'bash');
  const dir = await mkdtemp(join(tmpdir(), 'kiosk-build-test-'));
  try {
    const stub = join(dir, 'flutter-stub');
    const log = join(dir, 'flutter-calls.jsonl');
    const logger = join(dir, 'log.mjs');
    await writeFile(logger, "import {appendFileSync} from 'node:fs'; appendFileSync(process.env.FLUTTER_TEST_LOG, JSON.stringify(process.argv.slice(2))+'\\n');");
    await writeFile(stub, '#!/usr/bin/env bash\nnode "$FLUTTER_TEST_LOGGER" "$@"\n', { mode: 0o755 });
    const env = { ...process.env, FLUTTER_BIN: stub.replaceAll('\\','/'), FLUTTER_TEST_LOG: log, FLUTTER_TEST_LOGGER: logger.replaceAll('\\','/'), CMS_BASE_URL: ' https://cms.gigi-sports.com/ ' };
    // MSYS must not convert the --dart-define argument into a Windows path.
    if (process.platform === 'win32') env.MSYS_NO_PATHCONV = '1';
    const result = spawnSync(bash, ['scripts/vercel-build.sh'], { cwd: root, env, encoding: 'utf8', timeout: 30000 });
    assert.equal(result.status, 0, result.stderr || result.error?.message);
    const calls = (await readFile(log, 'utf8')).trim().split('\n').map(JSON.parse);
    assert.deepEqual(calls.at(-1), ['build', 'web', '--release', '--dart-define=CMS_BASE_URL=https://cms.gigi-sports.com']);
    await writeFile(log, '');
    const missing = spawnSync(bash, ['scripts/vercel-build.sh'], { cwd: root, env: { ...env, CMS_BASE_URL: '' }, encoding: 'utf8', timeout: 30000 });
    assert.notEqual(missing.status, 0);
    assert.match(missing.stderr, /CMS_BASE_URL is missing/);
    assert.equal(await readFile(log, 'utf8'), '');
    const config = JSON.parse(await readFile(join(root, 'vercel.json'), 'utf8'));
    assert.equal(config.buildCommand, 'bash scripts/vercel-build.sh');
    assert.equal(config.outputDirectory, 'build/web');
  } finally {
    // The only removed directory is this test's uniquely-created temporary tree.
    const target = resolve(dir);
    assert.equal(resolve(join(target, '..')), resolve(tmpdir()));
    assert.match(target.split(/[\\/]/).at(-1), /^kiosk-build-test-/);
    await rm(target, { recursive: true, force: true });
  }
});
