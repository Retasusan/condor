# how to use

## 1. install dependencies

```shell
bundle install
```

## 2. set up database

```shell
docker compose up -d
```

## 3. migrate database

```shell
bundle exec sequel -m db/migrate "postgres://postgres:password@127.0.0.1:5432/mydatabase"
```

## 4. make .env file

```shell
cp .env.example .env
```

## 5. run server

```shell
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
bundle exec falcon serve --bind http://127.0.0.1:9292 --count 1
```
