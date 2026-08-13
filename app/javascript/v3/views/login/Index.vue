<script>
// utils and composables
import { login } from '../../api/auth';
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import { required, email } from '@vuelidate/validators';
import { useVuelidate } from '@vuelidate/core';
import { SESSION_STORAGE_KEYS } from 'dashboard/constants/sessionStorage';
import SessionStorage from 'shared/helpers/sessionStorage';
// components
import NexusBrandHeader from '../../components/NexusBrandHeader.vue';
import SimpleDivider from '../../components/Divider/SimpleDivider.vue';
import FormInput from '../../components/Form/Input.vue';
import GoogleOAuthButton from '../../components/GoogleOauth/Button.vue';
import Spinner from 'shared/components/Spinner.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import MfaVerification from 'dashboard/components/auth/MfaVerification.vue';

const ERROR_MESSAGES = {
  'no-account-found': 'LOGIN.OAUTH.NO_ACCOUNT_FOUND',
  'business-account-only': 'LOGIN.OAUTH.BUSINESS_ACCOUNTS_ONLY',
  'saml-authentication-failed': 'LOGIN.SAML.API.ERROR_MESSAGE',
  'saml-not-enabled': 'LOGIN.SAML.API.ERROR_MESSAGE',
};

const IMPERSONATION_URL_SEARCH_KEY = 'impersonation';

export default {
  components: {
    FormInput,
    GoogleOAuthButton,
    Spinner,
    SimpleDivider,
    MfaVerification,
    NexusBrandHeader,
    Icon,
  },
  props: {
    ssoAuthToken: { type: String, default: '' },
    ssoAccountId: { type: String, default: '' },
    ssoConversationId: { type: String, default: '' },
    email: { type: String, default: '' },
    authError: { type: String, default: '' },
  },
  setup() {
    return {
      v$: useVuelidate(),
    };
  },
  data() {
    return {
      // We need to initialize the component with any
      // properties that will be used in it
      credentials: {
        email: '',
        password: '',
      },
      loginApi: {
        message: '',
        showLoading: false,
        hasErrored: false,
      },
      error: '',
      mfaRequired: false,
      mfaToken: null,
    };
  },
  validations() {
    return {
      credentials: {
        password: {
          required,
        },
        email: {
          required,
          email,
        },
      },
    };
  },
  computed: {
    ...mapGetters({ globalConfig: 'globalConfig/get' }),
    allowedLoginMethods() {
      return window.chatwootConfig.allowedLoginMethods || ['email'];
    },
    showGoogleOAuth() {
      return (
        this.allowedLoginMethods.includes('google_oauth') &&
        Boolean(window.chatwootConfig.googleOAuthClientId)
      );
    },
    showSignupLink() {
      return window.chatwootConfig.signupEnabled === 'true';
    },
    showSamlLogin() {
      return this.allowedLoginMethods.includes('saml');
    },
  },
  created() {
    if (this.ssoAuthToken) {
      this.submitLogin();
    }
    if (this.authError) {
      const messageKey = ERROR_MESSAGES[this.authError] ?? 'LOGIN.API.UNAUTH';
      // Use a method to get the translated text to avoid dynamic key warning
      const translatedMessage = this.getTranslatedMessage(messageKey);
      useAlert(translatedMessage);
      // wait for idle state
      this.requestIdleCallbackPolyfill(() => {
        // Remove the error query param from the url
        const { query } = this.$route;
        this.$router.replace({ query: { ...query, error: undefined } });
      });
    }
  },
  methods: {
    getTranslatedMessage(key) {
      // Avoid dynamic key warning by handling each case explicitly
      switch (key) {
        case 'LOGIN.OAUTH.NO_ACCOUNT_FOUND':
          return this.$t('LOGIN.OAUTH.NO_ACCOUNT_FOUND');
        case 'LOGIN.OAUTH.BUSINESS_ACCOUNTS_ONLY':
          return this.$t('LOGIN.OAUTH.BUSINESS_ACCOUNTS_ONLY');
        case 'LOGIN.API.UNAUTH':
        default:
          return this.$t('LOGIN.API.UNAUTH');
      }
    },
    // TODO: Remove this when Safari gets wider support
    // Ref: https://caniuse.com/requestidlecallback
    //
    requestIdleCallbackPolyfill(callback) {
      if (window.requestIdleCallback) {
        window.requestIdleCallback(callback);
      } else {
        // Fallback for safari
        // Using a delay of 0 allows the callback to be executed asynchronously
        // in the next available event loop iteration, similar to requestIdleCallback
        setTimeout(callback, 0);
      }
    },
    showAlertMessage(message) {
      // Reset loading, current selected agent
      this.loginApi.showLoading = false;
      this.loginApi.message = message;
      useAlert(this.loginApi.message);
    },
    handleImpersonation() {
      // Detects impersonation mode via URL and sets a session flag to prevent user settings changes during impersonation.
      const urlParams = new URLSearchParams(window.location.search);
      const impersonation = urlParams.get(IMPERSONATION_URL_SEARCH_KEY);
      if (impersonation) {
        SessionStorage.set(SESSION_STORAGE_KEYS.IMPERSONATION_USER, true);
      }
    },
    submitLogin() {
      this.loginApi.hasErrored = false;
      this.loginApi.showLoading = true;

      const credentials = {
        email: this.email
          ? decodeURIComponent(this.email)
          : this.credentials.email,
        password: this.credentials.password,
        sso_auth_token: this.ssoAuthToken,
        ssoAccountId: this.ssoAccountId,
        ssoConversationId: this.ssoConversationId,
      };

      login(credentials)
        .then(result => {
          // Check if MFA is required
          if (result?.mfaRequired) {
            this.loginApi.showLoading = false;
            this.mfaRequired = true;
            this.mfaToken = result.mfaToken;
            return;
          }

          this.handleImpersonation();
          this.showAlertMessage(this.$t('LOGIN.API.SUCCESS_MESSAGE'));
        })
        .catch(response => {
          // Reset URL Params if the authentication is invalid
          if (this.email) {
            window.location = '/app/login';
          }
          this.loginApi.hasErrored = true;
          this.showAlertMessage(
            response?.message || this.$t('LOGIN.API.UNAUTH')
          );
        });
    },
    submitFormLogin() {
      if (this.v$.credentials.email.$invalid && !this.email) {
        this.showAlertMessage(this.$t('LOGIN.EMAIL.ERROR'));
        return;
      }

      this.submitLogin();
    },
    handleMfaVerified() {
      // MFA verification successful, continue with login
      this.handleImpersonation();
      window.location = '/app';
    },
    handleMfaCancel() {
      // User cancelled MFA, reset state
      this.mfaRequired = false;
      this.mfaToken = null;
      this.credentials.password = '';
    },
  },
};
</script>

<template>
  <main
    class="dark relative flex min-h-screen w-full flex-col items-center justify-center overflow-hidden bg-[#0a1f1b] px-4 py-12 sm:px-6"
  >
    <div
      class="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_50%_18%,#163c32_0%,#0a1f1b_48%,#071412_100%)]"
    />

    <div class="relative z-10 mb-8 sm:mb-10">
      <NexusBrandHeader
        :brand-name="$t('LOGIN.BRAND_NAME')"
        :subtitle="$t('LOGIN.SUBTITLE')"
      />
    </div>

    <section v-if="mfaRequired" class="relative z-10 w-full max-w-md">
      <div
        class="rounded-2xl border border-[#c4a35a]/40 bg-[#0e241f]/90 p-8 shadow-[0_0_50px_rgba(196,163,90,0.12)]"
      >
        <MfaVerification
          :mfa-token="mfaToken"
          @verified="handleMfaVerified"
          @cancel="handleMfaCancel"
        />
      </div>
    </section>

    <section
      v-else
      class="relative z-10 w-full max-w-md rounded-2xl border border-[#c4a35a]/40 bg-[#0e241f]/90 p-8 shadow-[0_0_50px_rgba(196,163,90,0.12)] sm:p-10"
      :class="{ 'animate-wiggle': loginApi.hasErrored }"
    >
      <div v-if="!email">
        <div
          v-if="showGoogleOAuth || showSamlLogin"
          class="mb-6 flex flex-col gap-3"
        >
          <GoogleOAuthButton v-if="showGoogleOAuth" />
          <div v-if="showSamlLogin" class="text-center">
            <router-link
              to="/app/login/sso"
              class="inline-flex w-full items-center justify-center rounded-xl border border-slate-700 bg-slate-800/80 px-4 py-3 text-slate-100 transition-colors hover:border-blue-500/50 hover:bg-slate-800"
            >
              <Icon
                icon="i-lucide-lock-keyhole"
                class="size-5 text-slate-300"
              />
              <span class="ml-2 text-base font-medium">
                {{ $t('LOGIN.SAML.LABEL') }}
              </span>
            </router-link>
          </div>
          <SimpleDivider
            v-if="showGoogleOAuth || showSamlLogin"
            :label="$t('COMMON.OR')"
            class="uppercase text-slate-500"
          />
        </div>

        <form class="space-y-5" @submit.prevent="submitFormLogin">
          <FormInput
            v-model="credentials.email"
            name="email_address"
            type="text"
            icon="mail"
            variant="nexus"
            data-testid="email_input"
            :tabindex="1"
            required
            :label="$t('LOGIN.EMAIL.LABEL')"
            :placeholder="$t('LOGIN.EMAIL.PLACEHOLDER')"
            :has-error="v$.credentials.email.$error"
            @input="v$.credentials.email.$touch"
          />
          <div class="space-y-2">
            <FormInput
              v-model="credentials.password"
              type="password"
              name="password"
              icon="lock-closed"
              variant="nexus"
              data-testid="password_input"
              required
              :tabindex="2"
              :label="$t('LOGIN.PASSWORD.LABEL')"
              :placeholder="$t('LOGIN.PASSWORD.PLACEHOLDER')"
              :has-error="v$.credentials.password.$error"
              @input="v$.credentials.password.$touch"
            />
            <div
              v-if="!globalConfig.disableUserProfileUpdate"
              class="flex justify-end"
            >
              <router-link
                to="auth/reset/password"
                class="text-sm font-medium text-white/50 transition-colors hover:text-white/80"
                tabindex="4"
              >
                {{ $t('LOGIN.FORGOT_PASSWORD') }}
              </router-link>
            </div>
          </div>

          <button
            type="submit"
            data-testid="submit_button"
            class="flex w-full items-center justify-center rounded-xl bg-[#1f5c48] px-4 py-3.5 text-base font-semibold text-white shadow-lg shadow-black/20 transition-colors hover:bg-[#247056] disabled:cursor-not-allowed disabled:opacity-60"
            :tabindex="3"
            :disabled="loginApi.showLoading"
          >
            <Spinner
              v-if="loginApi.showLoading"
              color-scheme="primary"
              size=""
            />
            <span v-else>{{ $t('LOGIN.SUBMIT') }}</span>
          </button>
        </form>

        <p
          v-if="showSignupLink"
          class="mt-6 text-center text-sm text-slate-400"
        >
          {{ $t('COMMON.OR') }}
          <router-link
            to="auth/signup"
            class="font-medium text-[#c4a35a] hover:text-[#e0c27a]"
          >
            {{ $t('LOGIN.CREATE_NEW_ACCOUNT') }}
          </router-link>
        </p>
      </div>
      <div v-else class="flex items-center justify-center py-10">
        <Spinner color-scheme="primary" size="" />
      </div>
    </section>

    <footer class="relative z-10 mt-8 text-center text-sm text-white/50 sm:mt-10">
      {{ $t('LOGIN.FOOTER_BY') }}
      <a
        href="https://hitechdesenvolvimento.com.br/"
        target="_blank"
        rel="noopener noreferrer"
        class="font-medium text-[#c4a35a] transition-colors hover:text-[#e0c27a]"
      >
        {{ $t('LOGIN.FOOTER_BRAND') }}
      </a>
      {{ $t('LOGIN.FOOTER_SUFFIX') }}
    </footer>
  </main>
</template>
