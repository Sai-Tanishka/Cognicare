from fastapi import FastAPI

app = FastAPI(
    title="Cognicare API",
    description="Backend API for the Cognicare cognitive wellness platform",
    version="1.0.0"
)


@app.get("/")
def root():
    return {
        "message": "Welcome to Cognicare API",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }