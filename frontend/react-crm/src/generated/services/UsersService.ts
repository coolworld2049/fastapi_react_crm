/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { Body_create_user_open_api_v1_users_open_post } from '../models/Body_create_user_open_api_v1_users_open_post';
import type { Body_update_user_me_api_v1_users_me_put } from '../models/Body_update_user_me_api_v1_users_me_put';
import type { User } from '../models/User';
import type { UserCreate } from '../models/UserCreate';
import type { UserUpdate } from '../models/UserUpdate';

import type { CancelablePromise } from '../core/CancelablePromise';
import { OpenAPI } from '../core/OpenAPI';
import { request as __request } from '../core/request';

export class UsersService {

    /**
     * Read Users
     * Retrieve users.
     * @param skip 
     * @param limit 
     * @returns User Successful Response
     * @throws ApiError
     */
    public static readUsersApiV1UsersGet(
skip?: number,
limit: number = 100,
): CancelablePromise<Array<User>> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/api/v1/users/',
            query: {
                'skip': skip,
                'limit': limit,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Create User
     * Create new user.
     * @param requestBody 
     * @returns User Successful Response
     * @throws ApiError
     */
    public static createUserApiV1UsersPost(
requestBody: UserCreate,
): CancelablePromise<User> {
        return __request(OpenAPI, {
            method: 'POST',
            url: '/api/v1/users/',
            body: requestBody,
            mediaType: 'application/json',
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Read User Me
     * Get current user.
     * @returns User Successful Response
     * @throws ApiError
     */
    public static readUserMeApiV1UsersMeGet(): CancelablePromise<User> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/api/v1/users/me',
        });
    }

    /**
     * Update User Me
     * Update own user.
     * @param requestBody 
     * @returns User Successful Response
     * @throws ApiError
     */
    public static updateUserMeApiV1UsersMePut(
requestBody?: Body_update_user_me_api_v1_users_me_put,
): CancelablePromise<User> {
        return __request(OpenAPI, {
            method: 'PUT',
            url: '/api/v1/users/me',
            body: requestBody,
            mediaType: 'application/json',
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Create User Open
     * Create new user without the need to be logged in.
     * @param requestBody 
     * @returns User Successful Response
     * @throws ApiError
     */
    public static createUserOpenApiV1UsersOpenPost(
requestBody: Body_create_user_open_api_v1_users_open_post,
): CancelablePromise<User> {
        return __request(OpenAPI, {
            method: 'POST',
            url: '/api/v1/users/open',
            body: requestBody,
            mediaType: 'application/json',
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Read User By Id
     * Get a specific user by id.
     * @param userId 
     * @returns User Successful Response
     * @throws ApiError
     */
    public static readUserByIdApiV1UsersUserIdGet(
userId: number,
): CancelablePromise<User> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/api/v1/users/{user_id}',
            path: {
                'user_id': userId,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Update User
     * Update a user.
     * @param userId 
     * @param requestBody 
     * @returns User Successful Response
     * @throws ApiError
     */
    public static updateUserApiV1UsersUserIdPut(
userId: number,
requestBody: UserUpdate,
): CancelablePromise<User> {
        return __request(OpenAPI, {
            method: 'PUT',
            url: '/api/v1/users/{user_id}',
            path: {
                'user_id': userId,
            },
            body: requestBody,
            mediaType: 'application/json',
            errors: {
                422: `Validation Error`,
            },
        });
    }

}
