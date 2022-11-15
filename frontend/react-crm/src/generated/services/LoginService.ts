/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { Body_login_access_token_api_v1_auth_jwt_login_post } from '../models/Body_login_access_token_api_v1_auth_jwt_login_post';
import type { Token } from '../models/Token';

import type { CancelablePromise } from '../core/CancelablePromise';
import { OpenAPI } from '../core/OpenAPI';
import { request as __request } from '../core/request';

export class LoginService {

    /**
     * Login Access Token
     * OAuth2 compatible token login, get an access token for future requests
     * @param formData 
     * @returns Token Successful Response
     * @throws ApiError
     */
    public static loginAccessTokenApiV1AuthJwtLoginPost(
formData: Body_login_access_token_api_v1_auth_jwt_login_post,
): CancelablePromise<Token> {
        return __request(OpenAPI, {
            method: 'POST',
            url: '/api/v1/auth/jwt/login',
            formData: formData,
            mediaType: 'application/x-www-form-urlencoded',
            errors: {
                422: `Validation Error`,
            },
        });
    }

}
