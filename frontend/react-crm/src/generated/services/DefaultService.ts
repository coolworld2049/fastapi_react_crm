/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { CancelablePromise } from '../core/CancelablePromise';
import { OpenAPI } from '../core/OpenAPI';
import { request as __request } from '../core/request';

export class DefaultService {

    /**
     * Root
     * Root GET
     * @returns any Successful Response
     * @throws ApiError
     */
    public static rootGet(): CancelablePromise<any> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/',
        });
    }

}
