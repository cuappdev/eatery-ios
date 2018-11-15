/// <reference types="node" />
import contentType = require('content-type');
import http = require('http');
import https = require('https');
import proxy = require('./proxy');
export declare const deps: {
    readonly proxy: typeof proxy.default;
    readonly isStream: any;
    readonly contentType: typeof contentType;
    readonly http: typeof http;
    readonly https: typeof https;
};
