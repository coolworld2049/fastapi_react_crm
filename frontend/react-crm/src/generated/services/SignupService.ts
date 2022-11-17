/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { Body_signup_api_v1_auth_jwt_signup_post } from '../models/Body_signup_api_v1_auth_jwt_signup_post';

import type { CancelablePromise } from '../core/CancelablePromise';
import { OpenAPI } from '../core/OpenAPI';
import { request as __request } from '../core/request';

export class SignupService {

    /**
     * Signup
     * @param formData 
     * @returns any Successful Response
     * @throws ApiError
     */
    public static signupApiV1AuthJwtSignupPost(
formData: Body_signup_api_v1_auth_jwt_signup_post,
): CancelablePromise<any> {
        return __request(OpenAPI, {
            method: 'POST',
            url: '/api/v1/auth/jwt/signup',
            formData: formData,
            mediaType: 'application/x-www-form-urlencoded',
            errors: {
                422: `Validation Error`,
            },
        });
    }

}
